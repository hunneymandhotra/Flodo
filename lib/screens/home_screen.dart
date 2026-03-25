import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_form_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.filteredTasks;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Premium light background
      appBar: AppBar(
        title: const Text(
          "Task Manager",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0, letterSpacing: -0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => taskProvider.fetchTasks(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context, taskProvider),
          Expanded(
            child: taskProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTasks.isEmpty
                    ? _buildEmptyState(context)
                    : _buildTaskList(context, filteredTasks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskForm(context),
        label: const Text("Add Task"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 4.0,
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.0),
          bottomRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10.0, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: provider.setSearchQuery,
            decoration: InputDecoration(
              hintText: "Search tasks...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12.0),
          // Filter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Filter by Status:", style: TextStyle(fontWeight: FontWeight.w600)),
              DropdownButton<TaskStatus?>(
                value: provider.filterStatus,
                underline: Container(),
                items: [
                  const DropdownMenuItem(value: null, child: Text("All Tasks")),
                  ...TaskStatus.values.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status.toShortString()));
                  }),
                ],
                onChanged: provider.setFilterStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16.0, bottom: 80.0),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onEdit: () => _showTaskForm(context, taskToEdit: task),
          onDelete: () => _showDeleteConfirmation(context, task.id!),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16.0),
          Text(
            "No tasks found",
            style: TextStyle(fontSize: 18.0, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8.0),
          Text(
            "Try adjusting your filters or search query",
            style: TextStyle(fontSize: 14.0, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  void _showTaskForm(BuildContext context, {Task? taskToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => TaskFormModal(taskToEdit: taskToEdit),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).deleteTask(id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
