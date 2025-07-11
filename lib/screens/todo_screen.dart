import 'package:day_05_todo_list_ui/providers/todo_provider.dart';
import 'package:day_05_todo_list_ui/widegts/add_task_bottom_sheet.dart';
import 'package:day_05_todo_list_ui/widegts/custom_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  late AnimationController _fbAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();

    _fbAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fbAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fbAnimationController.dispose();
    super.dispose();
  }

  // ============ main ui ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return CustomScrollView(
            slivers: [CustomSliverAppBar(provider: todoProvider)],
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddTaskBottomSheet(context),
              label: const Text('Add Task'),
              icon: const Icon(Icons.add_rounded),
            ),
          );
        },
      ),
    );
  }

  // show Bottomsheet Method

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTaskBottomSheet(),
    );
  }
}
