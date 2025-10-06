import 'package:flutter/material.dart';
import 'main.dart';
import 'report.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class ReportsPage extends StatefulWidget {
  final List<Report> reports;

  const ReportsPage({super.key, required this.reports});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _filterStatus = 'الكل';
  bool _isLoading = true;
  List<Report> _apiReports = [];

  final List<String> _statusFilters = ['الكل', 'قيد المراجعة', 'مرفوض', 'سيتم التواصل'];

  final String apiUrl = Config.reportsUrl;

  @override
  void initState() {
    super.initState();
    _loadReportsFromAPI();
  }

  Future<void> _loadReportsFromAPI() async {
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => _isLoading = false);
      _showSnackbar('يجب تسجيل الدخول أولاً');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        setState(() {
          _apiReports = body.map((json) => Report.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        final errorBody = jsonDecode(response.body);
        setState(() => _isLoading = false);
        _showSnackbar('فشل في جلب البلاغات: ${errorBody['detail'] ?? response.statusCode}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('فشل الاتصال بالسيرفر: $e');
    }
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

  List<Report> get _filteredReports {
    final allReports = [..._apiReports, ...widget.reports];
    if (_filterStatus == 'الكل') return allReports;
    return allReports.where((report) => report.status == _filterStatus).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'قيد المراجعة':
        return Colors.orange;
      case 'مرفوض':
        return Colors.red;
      case 'سيتم التواصل':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'قيد المراجعة':
        return Icons.access_time;
      case 'مرفوض':
        return Icons.cancel;
      case 'سيتم التواصل':
        return Icons.phone;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            'بلاغاتي',
            style: TextStyle(
              fontSize: _fontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadReportsFromAPI,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withOpacity(0.05),
              child: Row(
                children: [
                  Text(
                    'تصفية حسب:',
                    style: TextStyle(
                      fontSize: _fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filterStatus,
                          isExpanded: true,
                          items: _statusFilters.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: _fontSize(context, 14),
                                  color: AppColors.dark,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _filterStatus = value!;
                            });
                          },
                          icon: Icon(Icons.filter_list, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filteredReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.report_gmailerrorred_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد بلاغات',
                                style: TextStyle(
                                  fontSize: _fontSize(context, 18),
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _filterStatus == 'الكل' 
                                    ? 'لم تقم بإرسال أي بلاغات حتى الآن'
                                    : 'لا توجد بلاغات بحالة "$_filterStatus"',
                                style: TextStyle(
                                  fontSize: _fontSize(context, 14),
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadReportsFromAPI,
                                child: Text('إعادة تحميل'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadReportsFromAPI,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredReports.length,
                            itemBuilder: (context, index) {
                              final report = _filteredReports[index];
                              return _buildReportCard(report, context);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Report report, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(report.status).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(report.status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    report.type,
                    style: TextStyle(
                      fontSize: _fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(report.status),
                        size: _fontSize(context, 14),
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.status,
                        style: TextStyle(
                          fontSize: _fontSize(context, 12),
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.carNumber.isNotEmpty && report.carNumber != 'لا يوجد')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: _fontSize(context, 16),
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'رقم السيارة: ${report.carNumber}',
                            style: TextStyle(
                              fontSize: _fontSize(context, 14),
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (report.imageName != null && report.imageName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo,
                          size: _fontSize(context, 16),
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'مرفق صورة',
                            style: TextStyle(
                              fontSize: _fontSize(context, 14),
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (report.details.isNotEmpty && report.details != 'لا توجد تفاصيل إضافية')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.description,
                          size: _fontSize(context, 16),
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'التفاصيل: ${report.details}',
                            style: TextStyle(
                              fontSize: _fontSize(context, 14),
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (report.adminResponse != null && report.adminResponse!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              size: _fontSize(context, 16),
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'رد الإدارة:',
                              style: TextStyle(
                                fontSize: _fontSize(context, 14),
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          report.adminResponse!,
                          style: TextStyle(
                            fontSize: _fontSize(context, 13),
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: _fontSize(context, 14),
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(report.date),
                        style: TextStyle(
                          fontSize: _fontSize(context, 12),
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}