import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'core/widgets/themed_background.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _selectedFilter = 'الكل';

  final List<Map<String, dynamic>> _reports = [
    {
      'id': 'RPT001',
      'title': 'تحرش مروري',
      'description': 'سيارة تسير بسرعة عالية في الشارع الرئيسي',
      'date': '2024-01-15',
      'status': 'مغلق',
      'location': 'شارع الملك فيصل',
      'icon': Icons.speed,
      'color': Colors.white,
    },
    {
      'id': 'RPT002',
      'title': 'إعاقة حركة المرور',
      'description': 'سيارة متوقفة في مكان ممنوع للوقوف',
      'date': '2024-01-14',
      'status': 'قيد المراجعة',
      'location': 'مول الرياض',
      'icon': Icons.local_parking,
      'color': Colors.white70,
    },
    {
      'id': 'RPT003',
      'title': 'سرقة مركبة',
      'description': 'تم سرقة سيارة من أمام المبنى',
      'date': '2024-01-13',
      'status': 'مفتوح',
      'location': 'حي الملز',
      'icon': Icons.car_crash_sharp,
      'color': Colors.grey,
    },
    {
      'id': 'RPT004',
      'title': 'مخالفة إشارة مرور',
      'description': 'سيارة تجاوزت الإشارة الحمراء',
      'date': '2024-01-12',
      'status': 'مغلق',
      'location': 'تقاطع الملك عبدالعزيز',
      'icon': Icons.traffic,
      'color': Colors.white,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredReports = _getFilteredReports();
    return Scaffold(
      body: ThemedBackground(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        safeArea: true,
        child: Column(
          children: [
            _buildHeader(context, filteredReports.length),
            _buildFilterButtons(colorScheme),
            const SizedBox(height: 8),
            Expanded(
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 400),
                      child: SlideAnimation(
                        verticalOffset: 45.0,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildReportCard(context, report, colorScheme),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'بلاغاتي',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count بلاغ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons(ColorScheme colorScheme) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          _buildFilterButton('الكل', colorScheme),
          const SizedBox(width: 10),
          _buildFilterButton('مفتوح', colorScheme),
          const SizedBox(width: 10),
          _buildFilterButton('قيد المراجعة', colorScheme),
          const SizedBox(width: 10),
          _buildFilterButton('مغلق', colorScheme),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String filter, ColorScheme colorScheme) {
    final isSelected = _selectedFilter == filter;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? colorScheme.secondary
            : Colors.white.withOpacity(0.18),
        foregroundColor: isSelected ? colorScheme.onSecondary : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: isSelected ? 8 : 0,
      ),
      child: Text(
        filter,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, Map<String, dynamic> report, ColorScheme colorScheme) {
    return GlassContainer(
      height: 140,
      width: double.infinity,
      color: Colors.white.withOpacity(0.1),
      borderColor: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(22.0),
      borderWidth: 1.2,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: report['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                report['icon'],
                color: report['color'],
                size: 30,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    report['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    report['description'],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        report['date'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: report['color'].withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          report['status'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredReports() {
    if (_selectedFilter == 'الكل') {
      return _reports;
    }
    return _reports.where((report) => report['status'] == _selectedFilter).toList();
  }
}
