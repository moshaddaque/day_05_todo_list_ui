import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:day_05_todo_list_ui/models/todo.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static const String _channelKey = 'todo_app_channel';
  static const String _channelName = 'Todo App Notifications';
  static const String _channelDescription = 'Notifications for Todo App';

  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // No custom icon for now
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: _channelName,
          channelDescription: _channelDescription,
          defaultColor: const Color(0xFF6750A4),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          vibrationPattern: highVibrationPattern,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    // Request permission
    await requestPermission();
  }

  Future<bool> requestPermission() async {
    return await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Future<void> createTaskNotification(Todo todo) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: todo.id.hashCode,
        channelKey: _channelKey,
        title: todo.title,
        body: todo.description,
        notificationLayout: NotificationLayout.Default,
        color: todo.priorityColor,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        fullScreenIntent: false,
        criticalAlert: false,
        autoDismissible: true,
      ),
    );
  }

  Future<void> scheduleTaskNotification(Todo todo) async {
    if (todo.dueDate == null) return;

    // Schedule notification 30 minutes before due date
    final scheduledDate30Min = todo.dueDate!.subtract(const Duration(minutes: 30));
    
    // Only schedule if the date is in the future
    if (scheduledDate30Min.isAfter(DateTime.now())) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: todo.id.hashCode,
          channelKey: _channelKey,
          title: 'Upcoming Task: ${todo.title}',
          body: 'Due in 30 minutes: ${todo.description}',
          notificationLayout: NotificationLayout.Default,
          color: todo.priorityColor,
          category: NotificationCategory.Reminder,
          wakeUpScreen: true,
          fullScreenIntent: false,
          criticalAlert: false,
          autoDismissible: true,
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate30Min),
      );
    }
    
    // Schedule another notification 10 minutes before due date
    final scheduledDate10Min = todo.dueDate!.subtract(const Duration(minutes: 10));
    
    // Only schedule if the date is in the future
    if (scheduledDate10Min.isAfter(DateTime.now())) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: todo.id.hashCode + 500, // Different ID to avoid conflicts with 30 min notification
          channelKey: _channelKey,
          title: 'Task Due Soon: ${todo.title}',
          body: 'Only 10 minutes left to complete this task!',
          notificationLayout: NotificationLayout.Default,
          color: todo.priorityColor,
          category: NotificationCategory.Alarm, // Using Alarm category for urgency
          wakeUpScreen: true,
          fullScreenIntent: true, // Full screen intent for more visibility
          criticalAlert: false,
          autoDismissible: true,
        ),
        schedule: NotificationCalendar.fromDate(date: scheduledDate10Min),
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  // Call this method when a task is completed
  Future<void> showTaskCompletedNotification(Todo todo) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: (todo.id.hashCode + 1000), // Different ID to avoid conflicts
        channelKey: _channelKey,
        title: 'Task Completed! 🎉',
        body: 'You have completed: ${todo.title}',
        notificationLayout: NotificationLayout.Default,
        color: Colors.green,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        fullScreenIntent: false,
        criticalAlert: false,
        autoDismissible: true,
      ),
    );
  }

  // Call this method when a task is due today
  Future<void> showTaskDueTodayNotification(List<Todo> todayTasks) async {
    if (todayTasks.isEmpty) return;

    final tasksCount = todayTasks.length;
    final taskNames = todayTasks.map((task) => task.title).join(', ');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: _channelKey,
        title: 'Tasks Due Today',
        body: 'You have $tasksCount task(s) due today: $taskNames',
        notificationLayout: NotificationLayout.Default,
        color: const Color(0xFF6750A4),
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        fullScreenIntent: false,
        criticalAlert: false,
        autoDismissible: true,
      ),
    );
  }
}