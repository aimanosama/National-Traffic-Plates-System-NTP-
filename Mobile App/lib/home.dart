import 'package:flutter/material.dart';
import 'main.dart';
import 'report_page.dart';
import 'report.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class HomePage extends StatefulWidget {
  final List<Report> reports;
  final void Function(Report) onReportAdded;

  const HomePage({
    super.key,
    required this.reports,
    required this.onReportAdded,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _reportTypes = ['السرعة الزائدة', 'إعاقة المرور', 'تحرش', 'سرقة', 'أخرى'];
  String? _selectedReportType;
  final TextEditingController _carNumberCtrl = TextEditingController();
  final TextEditingController _detailsCtrl = TextEditingController();
  String? _pickedImageName;
  bool isSending = false;
  bool _hasChosenMedia = false;

  final String apiUrl = Config.reportsUrl;

  @override
  void initState() {
    super.initState();
    _carNumberCtrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _carNumberCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_carNumberCtrl.text.isNotEmpty && _pickedImageName == null) {
      setState(() => _hasChosenMedia = true);
    }
  }

  void _uploadPhoto() {
    setState(() {
      _pickedImageName = 'صورة من المعرض.jpg';
      _hasChosenMedia = true;
      if (_carNumberCtrl.text.isNotEmpty) _carNumberCtrl.clear();
    });
    _showSnackbar('تم اختيار صورة (محاكاة)');
  }

  void _takePhoto() {
    setState(() {
      _pickedImageName = 'صورة من الكاميرا.jpg';
      _hasChosenMedia = true;
      if (_carNumberCtrl.text.isNotEmpty) _carNumberCtrl.clear();
    });
    _showSnackbar('التقاط صورة (محاكاة)');
  }

  void _removePhoto() {
    setState(() {
      _pickedImageName = null;
      _hasChosenMedia = false;
    });
    _showSnackbar('تم إزالة الصورة');
  }

  Future<void> _sendReportToAPI() async {
    setState(() => isSending = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showSnackbar('يجب تسجيل الدخول أولاً');
      setState(() => isSending = false);
      return;
    }

    final car = _carNumberCtrl.text.trim();
    final details = _detailsCtrl.text.isNotEmpty ? _detailsCtrl.text : 'لا توجد تفاصيل إضافية';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "type": _selectedReportType!,
          "car_number": car.isEmpty ? 'لا يوجد' : car,
          "image_name": _pickedImageName,
          "details": details,
        }),
      );

      setState(() => isSending = false);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        final newReport = Report(
          id: body['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          type: body['type'] ?? _selectedReportType!,
          carNumber: body['car_number'] ?? (car.isEmpty ? 'لا يوجد' : car),
          imageName: body['image_name'] ?? _pickedImageName,
          details: body['details'] ?? details,
          status: body['status'] ?? 'قيد المراجعة',
          date: body['date'] != null ? DateTime.parse(body['date']) : DateTime.now(),
          adminResponse: body['admin_response'],
        );

        widget.onReportAdded(newReport);
        _showSnackbar('تم إرسال البلاغ بنجاح وجاري مراجعته');
        _resetForm();
      } else {
        final errorBody = jsonDecode(response.body);
        _showSnackbar('فشل في إرسال البلاغ: ${errorBody['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      setState(() => isSending = false);
      _showSnackbar('فشل الاتصال بالسيرفر: $e');
      _createLocalReport();
    }
  }

  void _createLocalReport() {
    final car = _carNumberCtrl.text.trim();
    final details = _detailsCtrl.text.isNotEmpty ? _detailsCtrl.text : 'لا توجد تفاصيل إضافية';
    
    final newReport = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedReportType!,
      carNumber: car.isEmpty ? 'لا يوجد' : car,
      imageName: _pickedImageName,
      details: details,
      status: 'قيد المراجعة',
      date: DateTime.now(),
    );
    
    widget.onReportAdded(newReport);
    _showSnackbar('تم حفظ البلاغ محلياً (بانتظار الاتصال)');
    _resetForm();
  }

  void _sendReport() {
    if (_selectedReportType == null) {
      _showSnackbar('من فضلك اختر نوع البلاغ');
      return;
    }

    if (!_hasChosenMedia) {
      _showSnackbar('من فضلك اختر صورة أو اكتب رقم السيارة');
      return;
    }

    final car = _carNumberCtrl.text.trim();
    if (_pickedImageName == null && car.isEmpty) {
      _showSnackbar('من فضلك اكتب رقم السيارة أو اختر صورة');
      return;
    }

    if (_selectedReportType == 'أخرى' && _detailsCtrl.text.trim().isEmpty) {
      _showSnackbar('من فضلك اكتب تفاصيل البلاغ');
      return;
    }

    _sendReportToAPI();
  }

  void _resetForm() {
    setState(() {
      _carNumberCtrl.clear();
      _detailsCtrl.clear();
      _pickedImageName = null;
      _selectedReportType = null;
      _hasChosenMedia = false;
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double _fontSize(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return base * 0.85;
    if (width > 600) return base * 1.2;
    return base;
  }

  double _responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 350) return 12.0;
    if (width > 600) return 24.0;
    return 16.0;
  }

  double _responsiveCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 700) return 640.0;
    if (width < 350) return width * 0.96;
    return width * 0.92;
  }

  double _responsiveTopHeight(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    if (height < 600) return height * 0.25;
    if (height > 800) return height * 0.22;
    return height * 0.23;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final cardWidth = _responsiveCardWidth(context);
    final topHeight = _responsiveTopHeight(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopSection(topHeight),
              SizedBox(height: height < 600 ? 30 : 50),
              Expanded(child: _buildMainCard(cardWidth)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection(double topHeight) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: topHeight,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(34),
              bottomRight: Radius.circular(34),
            ),
          ),
        ),

        Positioned(
          top: 15,
          left: 12,
          child: Image.asset('assets/logo.png', 
            height: 25, 
            fit: BoxFit.fill, 
            errorBuilder: (_, __, ___) => const SizedBox.shrink()
          ),
        ),

        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: Column(
            children: [
              Text('نظامك الموثوق لسلامة الطرق', 
                textAlign: TextAlign.center, 
                style: TextStyle(
                  color: AppColors.white, 
                  fontSize: _fontSize(context, 18), 
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 6),
              Text('أبلغ عن المخالفات بسهولة وبسرعة عبر صورتك أو الكاميرا', 
                textAlign: TextAlign.center, 
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.95), 
                  fontSize: _fontSize(context, 13)
                )
              ),
              const SizedBox(height: 4),
              Text('ساعدنا في جعل الطرق أكثر أمناً في مصر', 
                textAlign: TextAlign.center, 
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.95), 
                  fontSize: _fontSize(context, 13)
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(double cardWidth) {
    return SingleChildScrollView(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -30),
          child: Container(
            width: cardWidth,
            margin: EdgeInsets.symmetric(horizontal: _responsivePadding(context) - 8),
            padding: EdgeInsets.all(_responsivePadding(context)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12), 
                  blurRadius: 16, 
                  offset: const Offset(0, 8)
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderRow(),
                const SizedBox(height: 20),
                _buildPhotoButtons(),
                const SizedBox(height: 16),
                _buildCarNumberInput(),
                const SizedBox(height: 14),
                if (_pickedImageName != null) _buildSelectedImage(),
                if (_pickedImageName != null) const SizedBox(height: 12),
                _buildDetailsSection(),
                const SizedBox(height: 16),
                _buildSendButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _sendReport,
          child: Text(
            'إبلاغ',
            style: TextStyle(
              color: AppColors.primary, 
              fontSize: _fontSize(context, 16), 
              fontWeight: FontWeight.w700
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedReportType,
              hint: Text('نوع البلاغ', 
                style: TextStyle(
                  color: AppColors.primary, 
                  fontSize: _fontSize(context, 14), 
                  fontWeight: FontWeight.w600
                )
              ),
              items: _reportTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(
                  type, 
                  style: TextStyle(
                    color: AppColors.dark, 
                    fontSize: _fontSize(context, 14)
                  )
                ),
              )).toList(),
              onChanged: (value) => setState(() => _selectedReportType = value),
              icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
              dropdownColor: AppColors.white,
              isExpanded: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoButtons() {
    final isTextEmpty = _carNumberCtrl.text.isEmpty;
    
    return Row(
      children: [
        _buildPhotoButton('صور', Icons.image, _uploadPhoto, isTextEmpty),
        const SizedBox(width: 10),
        _buildPhotoButton('كاميرا', Icons.camera_alt, _takePhoto, isTextEmpty),
      ],
    );
  }

  Widget _buildPhotoButton(String text, IconData icon, VoidCallback onPressed, bool isEnabled) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: isEnabled ? onPressed : null,
        icon: Icon(icon, size: _fontSize(context, 18)),
        label: Text(
          text, 
          style: TextStyle(
            fontSize: _fontSize(context, 14), 
            fontWeight: FontWeight.w600
          )
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary : Colors.grey,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: _fontSize(context, 14)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildCarNumberInput() {
    final hasImage = _pickedImageName != null;
    
    return TextField(
      controller: _carNumberCtrl,
      enabled: !hasImage,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: hasImage ? 'تم اختيار صورة - غير متاح' : 'اكتب رقم السيارة',
        hintStyle: TextStyle(
          color: hasImage ? Colors.grey : Colors.grey.shade500,
          fontSize: _fontSize(context, 14)
        ),
        filled: true,
        fillColor: hasImage ? Colors.grey.shade200 : AppColors.primary.withOpacity(0.04),
        contentPadding: EdgeInsets.symmetric(
          vertical: _fontSize(context, 16), 
          horizontal: 12
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: BorderSide.none
        ),
      ),
      style: TextStyle(
        fontSize: _fontSize(context, 15), 
        fontWeight: FontWeight.w600,
        color: hasImage ? Colors.grey : AppColors.dark
      ),
    );
  }

  Widget _buildSelectedImage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'الصورة المختارة: $_pickedImageName', 
              style: TextStyle(
                color: AppColors.primary, 
                fontSize: _fontSize(context, 12),
                fontWeight: FontWeight.w600
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _removePhoto,
            icon: Icon(Icons.close, color: Colors.red, size: _fontSize(context, 18)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final isOtherSelected = _selectedReportType == 'أخرى';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Text(
                'تفاصيل البلاغ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: _fontSize(context, 16),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isOtherSelected) 
                Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: _fontSize(context, 16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        
        TextField(
          controller: _detailsCtrl,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: isOtherSelected 
                ? 'اكتب تفاصيل البلاغ هنا... *' 
                : 'تفاصيل إضافية (اختياري)',
            hintStyle: TextStyle(
              color: isOtherSelected ? Colors.grey.shade600 : Colors.grey.shade500,
              fontSize: _fontSize(context, 13),
            ),
            filled: true,
            fillColor: AppColors.primary.withOpacity(0.04),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isOtherSelected ? AppColors.primary : Colors.grey.shade300,
                width: isOtherSelected ? 1.5 : 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isOtherSelected ? AppColors.primary : Colors.grey.shade300,
                width: isOtherSelected ? 1.5 : 1.0,
              ),
            ),
          ),
          style: TextStyle(
            fontSize: _fontSize(context, 14),
            color: AppColors.dark,
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSending ? null : _sendReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: _fontSize(context, 14)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isSending
            ? SizedBox(
                height: _fontSize(context, 20), 
                width: _fontSize(context, 20), 
                child: CircularProgressIndicator(
                  color: Colors.white, 
                  strokeWidth: 2.2
                )
              )
            : Text('إرسال البلاغ', 
                style: TextStyle(
                  color: AppColors.white, 
                  fontWeight: FontWeight.w700, 
                  fontSize: _fontSize(context, 16)
                )
              ),
      ),
    );
  }
}