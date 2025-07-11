import 'package:day_05_todo_list_ui/providers/todo_provider.dart';
import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final TodoProvider provider;
  const CustomSliverAppBar({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar();
  }
}
