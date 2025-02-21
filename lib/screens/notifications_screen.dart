import 'package:flutter/material.dart';
import 'package:expense_tracker/services/notification_service.dart';

/// Model class for a notification.
class AppNotification {
  final String title;
  final String body;
  final DateTime date;

  AppNotification({
    required this.title,
    required this.body,
    required this.date,
  });
}

/// A screen that displays the latest 10 notifications in a list.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the latest notifications from the service.
    // It is assumed that NotificationService().getLatestNotifications() returns a List<AppNotification>
    final List<AppNotification> notifications =
    NotificationService().getLatestNotifications();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(13, 17, 23, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(24, 31, 39, 1),
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          "No notifications",
          style: TextStyle(color: Colors.white),
        ),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final AppNotification notification = notifications[index];
          return Card(
            color: const Color.fromRGBO(24, 31, 39, 1),
            margin:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                notification.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                notification.body,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Text(
                // Display the time (HH:mm) of the notification.
                "${notification.date.hour.toString().padLeft(2, '0')}:${notification.date.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }
}
