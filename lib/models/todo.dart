import 'package:flutter/material.dart';

enum Priority { low, medium, high }

enum TaskStatus { pending, completed }

class Todo {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskStatus status;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.status = TaskStatus.pending,
  });

  Todo copyWith({
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    TaskStatus? status,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status.index,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: Priority.values[json['priority']],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      status: TaskStatus.values[json['status']],
    );
  }

  Color get priorityColor {
    switch (priority) {
      case Priority.high:
        return const Color(0xFFFF5252);
      case Priority.medium:
        return const Color(0xFFFF9800);
      case Priority.low:
        return const Color(0xFF4CAF50);
    }
  }

  IconData get priorityIcon {
    switch (priority) {
      case Priority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case Priority.medium:
        return Icons.keyboard_arrow_up_rounded;
      case Priority.low:
        return Icons.keyboard_arrow_down_rounded;
    }
  }
}
