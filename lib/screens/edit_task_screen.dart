import 'package:day_05_todo_list_ui/models/todo.dart';
import 'package:day_05_todo_list_ui/providers/todo_provider.dart';
import 'package:day_05_todo_list_ui/services/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EditTaskScreen extends StatefulWidget {
  final Todo todo;

  const EditTaskScreen({super.key, required this.todo});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime? selectedDate;
  late TimeOfDay? selectedTime;
  late Priority selectedPriority;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing todo data
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    selectedPriority = widget.todo.priority;
    
    // Initialize date and time if due date exists
    if (widget.todo.dueDate != null) {
      selectedDate = widget.todo.dueDate;
      selectedTime = TimeOfDay(hour: widget.todo.dueDate!.hour, minute: widget.todo.dueDate!.minute);
    } else {
      selectedDate = null;
      selectedTime = null;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTitleField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildDatePicker(),
            const SizedBox(height: 24),
            _buildPrioritySelector(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        hintText: 'Enter task title',
        prefixIcon: const Icon(Icons.title_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Enter task description',
        prefixIcon: const Icon(Icons.description_rounded),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      textInputAction: TextInputAction.newline,
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date & Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Date Picker
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedDate == null
                              ? 'Select date'
                              : DateFormat('MMM dd, yyyy').format(selectedDate!),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: selectedDate == null
                                ? Theme.of(context).colorScheme.outline
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selectedDate != null)
                        IconButton(
                          onPressed: () => setState(() {
                            selectedDate = null;
                            selectedTime = null;
                          }),
                          icon: const Icon(Icons.close_rounded),
                          iconSize: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Time Picker
            Expanded(
              child: InkWell(
                onTap: selectedDate != null ? _selectTime : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    // Gray out if date is not selected
                    gradient: selectedDate == null
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                            ],
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: selectedDate == null
                            ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedTime == null
                              ? 'Time'
                              : selectedTime!.format(context),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: selectedDate == null || selectedTime == null
                                ? Theme.of(context).colorScheme.outline.withOpacity(0.5)
                                : null,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: Priority.values.map((priority) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildPriorityChip(priority),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(Priority priority) {
    final isSelected = selectedPriority == priority;
    final color = _getPriorityColor(priority);

    return GestureDetector(
      onTap: () => setState(() => selectedPriority = priority),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? color
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getPriorityIcon(priority), color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              _getPriorityLabel(priority),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? color
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        // If time is not selected yet, show time picker automatically
        if (selectedTime == null) {
          _selectTime();
        }
      });
    }
  }
  
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                // Combine date and time if both are selected
                DateTime? combinedDateTime;
                if (selectedDate != null) {
                  if (selectedTime != null) {
                    combinedDateTime = DateTime(
                      selectedDate!.year,
                      selectedDate!.month,
                      selectedDate!.day,
                      selectedTime!.hour,
                      selectedTime!.minute,
                    );
                  } else {
                    combinedDateTime = selectedDate;
                  }
                }
                
                // Create updated todo with the same ID
                final updatedTodo = widget.todo.copyWith(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  dueDate: combinedDateTime,
                  priority: selectedPriority,
                );
                
                // Update the todo in the provider
                Provider.of<TodoProvider>(context, listen: false).updateTodo(updatedTodo);
                
                // Show notification if task has a due date
                if (combinedDateTime != null) {
                  NotificationHelper.showTaskAddedSnackBar(
                    context, 
                    updatedTodo,
                    isUpdate: true
                  );
                }
                
                // Return to previous screen
                Navigator.pop(context, updatedTodo);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }
}