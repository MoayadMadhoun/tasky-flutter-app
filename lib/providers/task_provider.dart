import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<Task> _tasks = [];
  String? _error;
  bool _loading = false;

  List<Task> get tasks => List.unmodifiable(_tasks);
  String? get error => _error;
  bool get isLoading => _loading;

  Future<List<Task>> fetchTasks() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.fetchTasks();
      _tasks = data;
      return _tasks;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Task? byId(int id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addTask(Task task) async {
    _error = null;
    notifyListeners();

    try {
      final created = await _api.createTask(task);
      _tasks = [created, ..._tasks];
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateExisting(Task task) async {
    _error = null;
    notifyListeners();

    try {
      final updated = await _api.updateTask(task);
      _tasks = _tasks.map((t) => t.id == updated.id ? updated : t).toList();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteById(int id) async {
    _error = null;
    notifyListeners();

    try {
      await _api.deleteTask(id);
      _tasks = _tasks.where((t) => t.id != id).toList();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}
