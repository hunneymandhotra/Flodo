import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormModal extends StatefulWidget {
  final Task? taskToEdit;

  const TaskFormModal({super.key, this.taskToEdit});

  @override
  State<TaskFormModal> createState() => _TaskFormModalState();
}

class _TaskFormModalState extends State<TaskFormModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TaskStatus _selectedStatus;
  int? _blockedByTaskId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? "");
    _descriptionController = TextEditingController(text: widget.taskToEdit?.description ?? "");
    _selectedDate = widget.taskToEdit?.dueDate ?? DateTime.now();
    _selectedStatus = widget.taskToEdit?.status ?? TaskStatus.to_do;
    _blockedByTaskId = widget.taskToEdit?.blockedBy;

    // Load draft if creating new task
    if (widget.taskToEdit == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final draft = await Provider.of<TaskProvider>(context, listen: false).loadDraft();
        if (draft != null && mounted) {
          setState(() {
            _titleController.text = draft['title'] ?? "";
            _descriptionController.text = draft['description'] ?? "";
          });
        }
      });
    }

    _titleController.addListener(_saveDraft);
    _descriptionController.addListener(_saveDraft);
  }

  void _saveDraft() {
    if (widget.taskToEdit == null) {
      Provider.of<TaskProvider>(context, listen: false).saveDraft(
        _titleController.text,
        _descriptionController.text,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final availableTasks = taskProvider.tasks.where((t) => t.id != widget.taskToEdit?.id).toList();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20.0,
        right: 20.0,
        top: 20.0,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.taskToEdit == null ? "Create Task" : "Edit Task",
                style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: "Due Date", border: OutlineInputBorder()),
                        child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: DropdownButtonFormField<TaskStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
                      items: TaskStatus.values.map((status) {
                        return DropdownMenuItem(value: status, child: Text(status.toShortString()));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedStatus = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              DropdownButtonFormField<int?>(
                value: _blockedByTaskId,
                decoration: const InputDecoration(labelText: "Blocked By (Optional)", border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text("None")),
                  ...availableTasks.map((t) {
                    return DropdownMenuItem<int?>(value: t.id, child: Text(t.title));
                  }),
                ],
                onChanged: (val) {
                  setState(() => _blockedByTaskId = val);
                },
              ),
              const SizedBox(height: 20.0),
              taskProvider.isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final task = Task(
                            id: widget.taskToEdit?.id,
                            title: _titleController.text,
                            description: _descriptionController.text,
                            dueDate: _selectedDate,
                            status: _selectedStatus,
                            blockedBy: _blockedByTaskId,
                          );

                          if (widget.taskToEdit == null) {
                            await taskProvider.addTask(task);
                            await taskProvider.clearDraft();
                          } else {
                            await taskProvider.updateTask(task);
                          }
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: Text(widget.taskToEdit == null ? "Save Task" : "Update Task"),
                    ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
