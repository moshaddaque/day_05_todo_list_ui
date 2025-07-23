import 'dart:convert';

import 'package:todozen/models/todo.dart';
import 'package:todozen/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  TodoProvider() {
    _loadTodos();
    _loadTheme();
    _checkTodayTasks();
  }

  List<Todo> _todos = [];
  bool _isDarkMode = false;
  int _selectedTabInndex = 0;

  List<Todo> get todos => _todos;
  bool get isDarkMode => _isDarkMode;
  int get selectedTabIndex => _selectedTabInndex;

  // Today's Todos
  List<Todo> get todayTodos {
    final today = DateTime.now();
    return _todos.where((todo) {
      if (todo.status == TaskStatus.completed) return false;
      if (todo.dueDate == null) {
        return DateUtils.isSameDay(todo.createdAt, today);
      }

      return DateUtils.isSameDay(todo.dueDate!, today);
    }).toList();
  }

  // upcomming todos
  List<Todo> get upcomingTodos {
    final today = DateTime.now();
    return _todos.where((todo) {
      if (todo.status == TaskStatus.completed) return false;
      if (todo.dueDate == null) return false;

      return todo.dueDate!.isAfter(today) &&
          !DateUtils.isSameDay(todo.dueDate!, today);
    }).toList();
  }

  //completed todos
  List<Todo> get completedTodos {
    return _todos.where((todo) => todo.status == TaskStatus.completed).toList();
  }

  // current tabs todos
  List<Todo> get currentTabTodos {
    switch (_selectedTabInndex) {
      case 0:
        return todayTodos;
      case 1:
        return upcomingTodos;
      case 2:
        return completedTodos;
      default:
        return todayTodos;
    }
  }

  // set tab index
  void setTabIndex(int index) {
    _selectedTabInndex = index;
    notifyListeners();
  }

  // toggle theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  // add todo
  void addTodo(Todo todo) {
    _todos.add(todo);
    // Ensure state is updated before saving
    notifyListeners();
    _saveTodos();
    
    // Create notification for the new task
    _notificationService.createTaskNotification(todo);
    
    // Schedule notification if due date exists
    if (todo.dueDate != null) {
      _notificationService.scheduleTaskNotification(todo);
    }
  }

  // delete todo
  void deleteTodo(String id) {
    // Find the todo before removing it
    final todo = _todos.firstWhere((element) => element.id == id, orElse: () => null as Todo);
    if (todo != null) {
      // Cancel any scheduled notifications for this todo
      _notificationService.cancelNotification(todo.id.hashCode);
      // Also cancel the 10-minute notification
      _notificationService.cancelNotification(todo.id.hashCode + 500);
    }
    
    // Find and remove the todo with the given id
    _todos.removeWhere((element) => element.id == id);
    // Ensure state is updated before saving
    notifyListeners();
    _saveTodos();
  }

  // update todo
  void updateTodo(Todo todo) {
    final index = _todos.indexWhere((element) => element.id == todo.id);
    if (index == -1) return;
    
    // Safety check to prevent index out of range errors
    if (index >= 0 && index < _todos.length) {
      // Cancel existing notifications
      _notificationService.cancelNotification(todo.id.hashCode);
      // Also cancel the 10-minute notification
      _notificationService.cancelNotification(todo.id.hashCode + 500);
      
      _todos[index] = todo;
      // Ensure state is updated before saving
      notifyListeners();
      _saveTodos();
      
      // Create new notification for the updated task
      _notificationService.createTaskNotification(todo);
      
      // Schedule notification if due date exists
      if (todo.dueDate != null) {
        _notificationService.scheduleTaskNotification(todo);
      }
    }
  }

  // toggle todo status
  void toggleTodoStatus(String id) {
    final index = _todos.indexWhere((element) => element.id == id);
    if (index == -1) return;
    
    // Safety check to prevent index out of range errors
    if (index >= 0 && index < _todos.length) {
      final todo = _todos[index];
      final newStatus = todo.status == TaskStatus.pending
          ? TaskStatus.completed
          : TaskStatus.pending;
      
      final updatedTodo = todo.copyWith(status: newStatus);
      _todos[index] = updatedTodo;
      
      // Ensure state is updated before saving
      notifyListeners();
      _saveTodos();
      
      // If task is completed, show completion notification and cancel scheduled notifications
      if (newStatus == TaskStatus.completed) {
        _notificationService.showTaskCompletedNotification(updatedTodo);
        _notificationService.cancelNotification(todo.id.hashCode);
        // Also cancel the 10-minute notification
        _notificationService.cancelNotification(todo.id.hashCode + 500);
      } else {
        // If task is marked as pending again, reschedule notification if it has a due date
        if (todo.dueDate != null) {
          _notificationService.scheduleTaskNotification(updatedTodo);
        }
      }
    }
  }

  // =========================== save data ===================

  // save theme
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  //save todos
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosJson = _todos.map((todo) => todo.toJson()).toList();
    await prefs.setString('todos', jsonEncode(todosJson));
  }

  //================= Load Data ================

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todosString = prefs.getString('todos');
    if (todosString != null) {
      final todosJson = jsonDecode(todosString) as List;
      _todos = todosJson.map((json) => Todo.fromJson(json)).toList();
      notifyListeners();
      
      // Reschedule notifications for pending tasks with due dates
      for (final todo in _todos) {
        if (todo.status == TaskStatus.pending && todo.dueDate != null) {
          _notificationService.scheduleTaskNotification(todo);
        }
      }
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
  
  // Check for tasks due today and send a notification
  Future<void> _checkTodayTasks() async {
    await Future.delayed(const Duration(seconds: 2)); // Small delay to ensure app is loaded
    _notificationService.showTaskDueTodayNotification(todayTodos);
  }
}
