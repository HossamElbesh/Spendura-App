import 'dart:async';
import 'package:expense_tracker/services/database_services.dart';
import 'package:expense_tracker/services/notification_service.dart';

class BudgetMonitorServices {
  Timer? _timer;

  /// This map holds the notification state per category:
  /// 0 = no notification sent,
  /// 1 = 90% threshold notification sent,
  /// 2 = budget exceeded notification sent.
  final Map<String, int> _notificationState = {};

  /// This map holds the last time a notification was sent for a category.
  final Map<String, DateTime?> _lastNotifiedTime = {};

  /// Starts monitoring budgets. Here we check every 10 seconds.
  void startMonitoring() {
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await checkBudgets();
    });
  }

  /// Checks all budgets to see if any have reached 90% or exceeded 100%.
  /// Notifications for each threshold are sent only once unless a new transaction occurs.
  Future<void> checkBudgets() async {
    final budgets = await DatabaseServices.instance.getAllBudgets();
    final notificationService = NotificationService();

    for (var budget in budgets) {
      final String category = budget['category'];
      final double budgetAmount = budget['amount'];
      final double spent = await _calculateSpent(category);
      final double ratio = spent / budgetAmount;

      // Get the latest transaction date for this category.
      final DateTime? latestTransactionDate = await _getLatestTransactionDate(category);

      // Get the current notification state (default is 0)
      int currentState = _notificationState[category] ?? 0;

      // Compute unique notification IDs.
      int baseId = category.hashCode & 0x7FFFFFFF;
      int id90 = baseId;               // For 90% threshold.
      int idExceeded = baseId + 1000000; // For budget exceeded.

      // If spending is 90% or more of the budget (but less than 100%).
      if (ratio >= 0.9 && ratio < 1.0) {
        if (currentState < 1) {
          await notificationService.showNotification(
            id: id90,
            title: 'Budget Warning!',
            body: 'Your $category budget is almost exceeded!',
          );
          _notificationState[category] = 1; // Mark 90% notification as sent.
        }
      }
      // If spending is equal to or exceeds the budget.
      else if (ratio >= 1.0) {
        // If we haven't sent any exceeded notification yet.
        if (currentState < 2) {
          await notificationService.showNotification(
            id: idExceeded,
            title: 'Budget Exceeded!',
            body: 'Your $category budget has been exceeded!',
          );
          _notificationState[category] = 2;
          _lastNotifiedTime[category] = latestTransactionDate;
        } else {
          // Already in exceeded state; check if a new transaction occurred.
          if (latestTransactionDate != null) {
            DateTime? lastNotified = _lastNotifiedTime[category];
            if (lastNotified == null || latestTransactionDate.isAfter(lastNotified)) {
              // New transaction detected – send a reminder.
              await notificationService.showNotification(
                id: idExceeded,
                title: 'Budget Reminder!',
                body: 'A new transaction in $category, your $category budget is exceeded!',
              );
              _lastNotifiedTime[category] = latestTransactionDate;
            }
          }
        }
      }
    }
  }

  /// Calculates the total spent for a given category.
  Future<double> _calculateSpent(String category) async {
    double totalSpent = 0.0;
    final transactions = await DatabaseServices.instance.getAllTransactions();

    for (var transaction in transactions) {
      // Assumes each transaction has properties: category, expenseOrIncome, and amount.
      if (transaction.category == category && transaction.expenseOrIncome == true) {
        totalSpent += transaction.amount;
      }
    }
    return totalSpent;
  }

  /// Returns the most recent transaction date for the given category.
  Future<DateTime?> _getLatestTransactionDate(String category) async {
    final transactions = await DatabaseServices.instance.getAllTransactions();
    DateTime? latest;
    for (var transaction in transactions) {
      if (transaction.category == category && transaction.expenseOrIncome == true) {
        final DateTime tDate = DateTime.fromMillisecondsSinceEpoch(transaction.date);
        if (latest == null || tDate.isAfter(latest)) {
          latest = tDate;
        }
      }
    }
    return latest;
  }

  /// Stops the periodic monitoring.
  void stopMonitoring() {
    _timer?.cancel();
  }
}
