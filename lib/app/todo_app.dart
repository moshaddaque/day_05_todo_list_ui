import 'package:day_05_todo_list_ui/app/theme.dart';
import 'package:day_05_todo_list_ui/providers/todo_provider.dart';
import 'package:day_05_todo_list_ui/screens/todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return MaterialApp(
            title: 'Todo App',
            debugShowCheckedModeBanner: false,
            theme: lightTheme(),
            darkTheme: darkTheme(),
            themeMode:
                todoProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const TodoScreen(),
          );
        },
      ),
    );
  }
}
