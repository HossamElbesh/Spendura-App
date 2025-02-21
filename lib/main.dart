import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/screens/intro_screen.dart';
import 'package:expense_tracker/screens/main_screen.dart';
import 'package:expense_tracker/services/notification_service.dart';
import 'package:expense_tracker/services/budget_monitor_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications.
  final notificationService = NotificationService();
  await notificationService.init();

  // Start monitoring budgets in the background.
  final budgetMonitor = BudgetMonitorServices();
  budgetMonitor.startMonitoring();

  final bool hasSeenOnboarding = await _checkOnboardingStatus();

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
}

Future<bool> _checkOnboardingStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasSeenOnboarding') ?? false;
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      home: hasSeenOnboarding ? const MainScreen() : const OnboardingScreen(),
    );
  }
}
