import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reports_page.dart';
import 'account_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({Key? key}) : super(key: key);

  static const routeName = '/app';

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 2; // ابدأ بالصفحة الرئيسية (الفهرس 2)

  final List<Widget> _pages = [
    const AccountPage(),
    const ReportsPage(),
    const HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true, // السماح للجسم بالامتداد خلف شريط التنقل
      body: _pages[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.person, size: 30, color: Colors.white),
          Icon(Icons.list_alt, size: 30, color: Colors.white),
          Icon(Icons.home, size: 30, color: Colors.white),
        ],
        color: colorScheme.secondary,
        buttonBackgroundColor: colorScheme.secondary,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}