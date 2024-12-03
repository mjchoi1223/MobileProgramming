import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front/screens/budget/budget_screen.dart';
import 'package:front/screens/budget_management/budget_management_screen.dart';
import 'package:front/screens/statistics/statistics_screen.dart';
import 'package:front/screens/settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  MainNavigation({this.initialIndex = 0});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _selectedIndex;
  String? userId;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      setState(() {
        userId = user.uid;
      });
    }
  }

  List<Widget> _getPages() {
    return [
      BudgetScreen(), // 가계부 화면
      BudgetManagementScreen(userId: userId ?? ''), // 예산 관리 화면
      userId == null
          ? Center(child: CircularProgressIndicator()) // userId가 없을 때 로딩 표시
          : StatisticsScreen(userId: userId!), // 통계 화면, userId 전달
      SettingsScreen(), // 설정 화면
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = _getPages();

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: '가계부',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: '예산',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 5,
      ),
    );
  }
}
