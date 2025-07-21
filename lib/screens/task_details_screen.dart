import 'package:day_05_todo_list_ui/models/todo.dart';
import 'package:day_05_todo_list_ui/providers/todo_provider.dart';
import 'package:day_05_todo_list_ui/screens/edit_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Todo todo;

  const TaskDetailsScreen({super.key, required this.todo});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.todo.status == TaskStatus.completed;
    final priorityColor = _getPriorityColor(widget.todo.priority);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedTodo = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditTaskScreen(todo: widget.todo),
                ),
              );
              
              // If the task was updated and we're back on this screen, refresh the UI
              if (updatedTodo != null && mounted) {
                setState(() {
                  // The UI will be updated with the latest todo data from the provider
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Priority Card
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: isCompleted 
                                      ? Colors.green 
                                      : Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: isCompleted 
                                    ? const Icon(Icons.check, size: 12, color: Colors.white) 
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCompleted ? 'Completed' : 'Pending',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Priority
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: priorityColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getPriorityIcon(widget.todo.priority),
                                  color: priorityColor,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getPriorityLabel(widget.todo.priority),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: priorityColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Title',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.todo.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Text(
              'Description',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.todo.description.isEmpty ? 'No description provided' : widget.todo.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: widget.todo.description.isEmpty 
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dates
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Created Date
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Created',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy - HH:mm').format(widget.todo.createdAt),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    if (widget.todo.dueDate != null) ...[  
                      const SizedBox(height: 16),
                      // Due Date
                      Row(
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 20,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due Date',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                _formatDueDate(widget.todo.dueDate!),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: priorityColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false).toggleTodoStatus(widget.todo.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCompleted 
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: isCompleted 
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isCompleted ? 'Mark as Pending' : 'Mark as Completed'),
          ),
        ),
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
      dateStr = DateFormat('MMM dd, yyyy').format(date);
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
  
  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }
  
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false).deleteTodo(widget.todo.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close details screen
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}