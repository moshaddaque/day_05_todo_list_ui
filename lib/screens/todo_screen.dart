import 'package:day_05_todo_list_ui/models/todo.dart';
import 'package:day_05_todo_list_ui/providers/todo_provider.dart';
import 'package:day_05_todo_list_ui/screens/task_details_screen.dart';
import 'package:day_05_todo_list_ui/widegts/add_task_bottom_sheet.dart';
import 'package:day_05_todo_list_ui/widegts/custom_sliver_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}



class _TodoScreenState extends State<TodoScreen> with TickerProviderStateMixin {
  late AnimationController _fbAnimationController;
  late Animation<double> _fabAnimation;
  late TabController _tabController;

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
    
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: Provider.of<TodoProvider>(context, listen: false).selectedTabIndex,
    );
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        Provider.of<TodoProvider>(context, listen: false).setTabIndex(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _fbAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ============ main ui ==========
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      body: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return OrientationBuilder(
            builder: (context, orientation) {
              return CustomScrollView(
                slivers: [
                  // App Bar with Tab Bar
                  CustomSliverAppBar(
                    provider: todoProvider,
                    tabController: _tabController,
                  ),
                  
                  // Task List
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _buildTaskList(todoProvider),
                  ),
                ],
              );
            },
          );
        },
      ),

      // floating action button
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

  // Task List Builder
  Widget _buildTaskList(TodoProvider provider) {
    final tasks = provider.currentTabTodos;
    
    if (tasks.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getEmptyStateIcon(provider.selectedTabIndex),
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _getEmptyStateMessage(provider.selectedTabIndex),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // Using SliverList instead of SliverAnimatedList for better stability
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Safety check to prevent RangeError
          if (index >= tasks.length) {
            return null;
          }
          
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildTaskCard(context, tasks[index], provider),
              ),
            ),
          );
        },
        childCount: tasks.length,
      ),
    );
  }
  
  // Task Card Builder
  Widget _buildTaskCard(BuildContext context, Todo todo, TodoProvider provider) {
    final priorityColor = _getPriorityColor(todo.priority);
    final isCompleted = todo.status == TaskStatus.completed;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(todo.id),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade300,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          provider.deleteTodo(todo.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${todo.title} deleted'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  provider.addTodo(todo);
                },
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: priorityColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: priorityColor.withOpacity(isCompleted ? 0.3 : 0.5),
              width: 1.5,
            ),
          ),
          child: InkWell(
            onTap: () {
              // Open task details screen
              _openTaskDetails(context, todo);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox
                  _buildAnimatedCheckbox(todo, provider),
                  const SizedBox(width: 16),
                  
                  // Task Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          todo.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted 
                                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (todo.description.isNotEmpty) ...[  
                          const SizedBox(height: 4),
                          // Description
                          Text(
                            todo.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              color: isCompleted 
                                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (todo.dueDate != null) ...[  
                          const SizedBox(height: 8),
                          // Due Date
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: isCompleted 
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                                    : priorityColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDueDate(todo.dueDate!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isCompleted 
                                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                                      : priorityColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Priority Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPriorityIcon(todo.priority),
                      color: priorityColor.withOpacity(isCompleted ? 0.5 : 1.0),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Animated Checkbox
  Widget _buildAnimatedCheckbox(Todo todo, TodoProvider provider) {
    final isCompleted = todo.status == TaskStatus.completed;
    final priorityColor = _getPriorityColor(todo.priority);
    
    return GestureDetector(
      onTap: () => provider.toggleTodoStatus(todo.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isCompleted ? priorityColor : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: priorityColor,
            width: 2,
          ),
        ),
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 18,
              )
            : null,
      ),
    );
  }
  
  // Helper Methods
  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);
    
    // Format time part
    final timeStr = DateFormat('HH:mm').format(date);
    
    // Format date part
    String dateStr;
    if (dateToCheck == today) {
      dateStr = 'Today';
    } else if (dateToCheck == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${date.day}/${date.month}/${date.year}';
    }
    
    // Check if time is midnight (00:00) - if so, don't show time
    if (date.hour == 0 && date.minute == 0) {
      return dateStr;
    }
    
    // Return combined date and time
    return '$dateStr, $timeStr';
  }
  
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return const Color(0xFFFF5252);
      case Priority.medium:
        return const Color(0xFFFF9800);
      case Priority.low:
        return const Color(0xFF4CAF50);
    }
  }
  
  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case Priority.medium:
        return Icons.keyboard_arrow_up_rounded;
      case Priority.low:
        return Icons.keyboard_arrow_down_rounded;
    }
  }
  
  IconData _getEmptyStateIcon(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Icons.today_rounded;
      case 1:
        return Icons.upcoming_rounded;
      case 2:
        return Icons.task_alt_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }
  
  String _getEmptyStateMessage(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'No tasks for today\nTap + to add a new task';
      case 1:
        return 'No upcoming tasks\nAll caught up!';
      case 2:
        return 'No completed tasks yet\nComplete a task to see it here';
      default:
        return 'No tasks found';
    }
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
  
  // Open Task Details Screen
  void _openTaskDetails(BuildContext context, Todo todo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(todo: todo),
      ),
    ).then((_) {
      // Refresh the UI when returning from details screen
      setState(() {});
    });
  }
}
