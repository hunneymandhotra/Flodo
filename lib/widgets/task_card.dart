import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'search_highlight_text.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final bool isBlocked = taskProvider.isBlocked(task);

    return Opacity(
      opacity: isBlocked ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        elevation: isBlocked ? 0 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: InkWell(
          onTap: isBlocked ? null : onEdit,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SearchHighlightText(
                        text: task.title,
                        query: taskProvider.searchQuery,
                        baseStyle: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: isBlocked ? Colors.grey[700] : Colors.black87,
                          decoration: isBlocked ? TextDecoration.lineThrough : null,
                        ),
                        highlightStyle: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                          backgroundColor: Colors.blue[50],
                        ),
                      ),
                    ),
                    _buildStatusChip(task.status, isBlocked),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14.0, color: Colors.blue[300]),
                        const SizedBox(width: 4.0),
                        Text(
                          DateFormat('MMM dd, yyyy').format(task.dueDate),
                          style: TextStyle(fontSize: 12.0, color: Colors.blue[700]),
                        ),
                      ],
                    ),
                    if (isBlocked) 
                      Row(
                        children: [
                          Icon(Icons.lock, size: 14.0, color: Colors.red[300]),
                          const SizedBox(width: 4.0),
                          Text(
                            "Blocked",
                            style: TextStyle(fontSize: 12.0, color: Colors.red[700]),
                          ),
                        ],
                      ),
                    if (!isBlocked)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status, bool isBlocked) {
    Color color;
    switch (status) {
      case TaskStatus.to_do:
        color = Colors.orange;
        break;
      case TaskStatus.in_progress:
        color = Colors.blue;
        break;
      case TaskStatus.done:
        color = Colors.green;
        break;
    }
    
    if (isBlocked) color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toShortString(),
        style: TextStyle(
          color: color,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
