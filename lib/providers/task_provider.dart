import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../data/database_helper.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = "";
  TaskStatus? _filterStatus;
  
  // Track Loading states specifically for Create/Update
  bool _isSaving = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get searchQuery => _searchQuery;
  TaskStatus? get filterStatus => _filterStatus;

  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Stretch Goal: Debounced Search timer
  Timer? _debounce;

  TaskProvider() {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final taskList = await _dbHelper.getAllTasks();
      _tasks.clear();
      _tasks.addAll(taskList);
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filtered and Searched list
  List<Task> get filteredTasks {
    return _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == null || task.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query;
      notifyListeners();
    });
  }

  void setFilterStatus(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    _isSaving = true;
    notifyListeners();
    
    // Requirement: Simulate 2-second delay
    await Future.delayed(const Duration(seconds: 2));
    
    await _dbHelper.insertTask(task);
    await fetchTasks();
    
    _isSaving = false;
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    _isSaving = true;
    notifyListeners();
    
    // Requirement: Simulate 2-second delay
    await Future.delayed(const Duration(seconds: 2));
    
    await _dbHelper.updateTask(task);
    await fetchTasks();
    
    _isSaving = false;
    notifyListeners();
  }

  Future<void> deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    await fetchTasks();
  }

  // Draft Management for Task Creation
  static const String _draftKey = 'task_draft';

  Future<void> saveDraft(String title, String description) async {
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'title': title,
      'description': description,
    };
    await prefs.setString(_draftKey, jsonEncode(draft));
  }

  Future<Map<String, String>?> loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftStr = prefs.getString(_draftKey);
    if (draftStr != null) {
      final decoded = jsonDecode(draftStr) as Map<String, dynamic>;
      return {
        'title': decoded['title'] as String,
        'description': decoded['description'] as String,
      };
    }
    return null;
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  // Check if a task is blocked
  bool isBlocked(Task task) {
    if (task.blockedBy == null) return false;
    // Task is blocked if the blocking task exists and is not "Done"
    final blockingTask = _tasks.firstWhere(
      (t) => t.id == task.blockedBy, 
      orElse: () => Task(title: "", description: "", dueDate: DateTime.now(), status: TaskStatus.done) // assume done if not found
    );
    return blockingTask.id != null && blockingTask.status != TaskStatus.done;
  }
}
