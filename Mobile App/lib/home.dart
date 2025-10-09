import 'package:flutter/material.dart';
import 'main.dart';
import 'report.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:image_picker/image_picker.dart';

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
  bool _isRecognizingPlate = false;

  final String apiUrl = Config.reportsUrl;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _uploadPhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        await _processImage(pickedFile, 'صورة من المعرض');
      }
    } catch (e) {
      _showSnackbar('خطأ في اختيار الصورة: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile != null) {
        await _processImage(pickedFile, 'صورة من الكاميرا');
      }
    } catch (e) {
      _showSnackbar('خطأ في الكاميرا: $e');
    }
  }

  Future<void> _processImage(XFile imageFile, String source) async {
    setState(() {
      _pickedImageName = '$source.jpg';
      _hasChosenMedia = true;
      _isRecognizingPlate = true;
    });

    // التعرف على لوحة السيارة تلقائياً باستخدام base64
    await _recognizeLicensePlateBase64(imageFile);

    setState(() {
      _isRecognizingPlate = false;
    });

    _showSnackbar('تم اختيار صورة ($source)');
  }

  Future<void> _recognizeLicensePlateBase64(XFile imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showSnackbar('يجب تسجيل الدخول أولاً');
      return;
    }

    try {
      // تحويل الصورة إلى base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var response = await http.post(
        Uri.parse('${Config.baseUrl}/api/v2/recognize-plate-base64'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "image": base64Image,
          "filename": "plate_image.jpg"
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true) {
          String carNumber = jsonResponse['car_number'];
          setState(() {
            _carNumberCtrl.text = carNumber;
          });
          _showSnackbar('تم التعرف على رقم السيارة: $carNumber');
        } else {
          String error = jsonResponse['error'] ?? 'فشل التعرف على لوحة السيارة';
          _showSnackbar(error);
        }
      } else {
        _showSnackbar('خطأ في الخادم: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('خطأ في التعرف على لوحة السيارة: $e');
    }
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
    }
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width > 700 ? 640.0 : width * 0.92;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopSection(),
              const SizedBox(height: 30),
              Expanded(child: _buildMainCard(cardWidth)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('نظامك الموثوق لسلامة الطرق', 
            textAlign: TextAlign.center, 
            style: TextStyle(
              color: AppColors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 10),
          Text('أبلغ عن المخالفات بسهولة وبسرعة عبر صورتك أو الكاميرا', 
            textAlign: TextAlign.center, 
            style: TextStyle(
              color: AppColors.white.withOpacity(0.95), 
              fontSize: 14
            )
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(double cardWidth) {
    return SingleChildScrollView(
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, -30),
          child: Container(
            width: cardWidth,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(16),
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
                if (_isRecognizingPlate) _buildRecognitionLoader(),
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
              fontSize: 16, 
              fontWeight: FontWeight.w700
            ),
          ),
        ),
        const Spacer(),
        DropdownButton<String>(
          value: _selectedReportType,
          hint: Text('نوع البلاغ', 
            style: TextStyle(
              color: AppColors.primary, 
              fontSize: 14, 
              fontWeight: FontWeight.w600
            )
          ),
          items: _reportTypes.map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          )).toList(),
          onChanged: (value) => setState(() => _selectedReportType = value),
        ),
      ],
    );
  }

  Widget _buildPhotoButtons() {
    return Row(
      children: [
        _buildPhotoButton('صور', Icons.image, _uploadPhoto),
        const SizedBox(width: 10),
        _buildPhotoButton('كاميرا', Icons.camera_alt, _takePhoto),
      ],
    );
  }

  Widget _buildPhotoButton(String text, IconData icon, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildRecognitionLoader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'جاري التعرف على لوحة السيارة...',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
            ),
          ),
        ],
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
        hintText: hasImage ? 'تم التعرف على رقم السيارة تلقائياً' : 'اكتب رقم السيارة',
        hintStyle: TextStyle(
          color: hasImage ? Colors.green : Colors.grey.shade500,
          fontSize: 14
        ),
        filled: true,
        fillColor: hasImage ? Colors.green.shade50 : AppColors.primary.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), 
          borderSide: BorderSide.none
        ),
      ),
      style: TextStyle(
        fontSize: 15, 
        fontWeight: FontWeight.w600,
        color: hasImage ? Colors.green : AppColors.dark
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
                fontSize: 12,
                fontWeight: FontWeight.w600
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: _removePhoto,
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل البلاغ',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _detailsCtrl,
          maxLines: 3,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'تفاصيل إضافية (اختياري)',
            filled: true,
            fillColor: AppColors.primary.withOpacity(0.04),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: isSending ? null : _sendReport,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isSending
          ? const SizedBox(
              height: 20, 
              width: 20, 
              child: CircularProgressIndicator(color: Colors.white)
            )
          : const Text('إرسال البلاغ', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}