import 'dart:convert';

enum TaskStatus { to_do, in_progress, done }

extension TaskStatusExtension on TaskStatus {
  String toShortString() {
    switch (this) {
      case TaskStatus.to_do:
        return "To-Do";
      case TaskStatus.in_progress:
        return "In Progress";
      case TaskStatus.done:
        return "Done";
    }
  }

  static TaskStatus fromShortString(String value) {
    switch (value) {
      case "To-Do":
        return TaskStatus.to_do;
      case "In Progress":
        return TaskStatus.in_progress;
      case "Done":
        return TaskStatus.done;
      default:
        return TaskStatus.to_do;
    }
  }
}

class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final int? blockedBy; // ID of the blocking task

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status.toShortString(),
      'blocked_by': blockedBy,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['due_date']),
      status: TaskStatusExtension.fromShortString(map['status']),
      blockedBy: map['blocked_by'],
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    int? blockedBy,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }
}
