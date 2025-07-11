import 'dart:convert';

import 'package:day_05_todo_list_ui/models/todo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoProvider extends ChangeNotifier {
  TodoProvider() {
    _loadTodos();
    _loadTheme();
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
    _saveTodos();
    notifyListeners();
  }

  // delete todo
  void deleteTodo(String id) {
    _todos.removeWhere((element) => element.id == id);
    _saveTodos();
    notifyListeners();
  }

  // update todo
  void updateTodo(Todo todo) {
    final index = _todos.indexWhere((element) => element.id == todo.id);
    if (index == -1) return;
    _todos[index] = todo;
    _saveTodos();
    notifyListeners();
  }

  // toggle todo status
  void toggleTodoStatus(String id) {
    final index = _todos.indexWhere((element) => element.id == id);
    if (index == -1) return;
    final todo = _todos[index];
    _todos[index] = todo.copyWith(
      status:
          todo.status == TaskStatus.pending
              ? TaskStatus.completed
              : TaskStatus.pending,
    );
    _saveTodos();
    notifyListeners();
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
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}
