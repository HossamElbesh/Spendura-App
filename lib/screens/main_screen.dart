import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/add_screen.dart';
import 'package:expense_tracker/screens/analysis_screen.dart';
import 'package:expense_tracker/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import 'budget_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // List of screens managed by MainScreen
  final List<Widget> _screens = [
    const HomeScreen(),
    BudgetScreen(),
    const AddScreen(),
    AnalysisScreen(),
    const SettingScreen(),
  ];

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: _screens[_selectedIndex], // Display selected screen here
      bottomNavigationBar: MyBottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
