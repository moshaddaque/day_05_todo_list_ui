import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:day_05_todo_list_ui/models/todo.dart';
import 'package:day_05_todo_list_ui/services/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationHelper {
  static final NotificationService _notificationService = NotificationService();
  
  // Check notification permission and request if not granted
  static Future<void> checkAndRequestPermission(BuildContext context) async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await _showPermissionDialog(context);
    }
  }
  
  // Show a dialog to request notification permission
  static Future<void> _showPermissionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allow Notifications'),
        content: const Text(
          'Our app would like to send you notifications for your tasks and reminders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Don\'t Allow',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _notificationService.requestPermission();
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }
  
  // Show a snackbar when a task is added or updated with notification info
  static void showTaskAddedSnackBar(BuildContext context, Todo todo, {bool isUpdate = false}) {
    final hasReminder = todo.dueDate != null;
    final snackBar = SnackBar(
      content: Text(
        hasReminder
            ? 'Task "${todo.title}" ${isUpdate ? 'updated' : 'added'} with reminders at 30 and 10 minutes before due time'
            : 'Task "${todo.title}" ${isUpdate ? 'updated' : 'added'}'
      ),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // Show a snackbar when a task is completed
  static void showTaskCompletedSnackBar(BuildContext context, Todo todo) {
    final snackBar = SnackBar(
      content: Text('Task "${todo.title}" completed! 🎉'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}