import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Task>> fetchTasks() async {
    final uri = Uri.parse('$baseUrl/todos?_limit=20');
    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to load tasks (code: ${res.statusCode})');
    }

    final decoded = jsonDecode(res.body) as List<dynamic>;
    return decoded.map((e) {
      final m = e as Map<String, dynamic>;
      return Task.fromJson({
        ...m, 'description': 'Task #${m['id']} from API (JSONPlaceholder).',
      });
    }).toList();
  }

  Future<Task> createTask(Task task) async {
    final uri = Uri.parse('$baseUrl/todos');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(task.toJson()),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Failed to create task (code: ${res.statusCode})');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return task.copyWith(id: (decoded['id'] as num?)?.toInt() ?? task.id);
  }

  Future<Task> updateTask(Task task) async {
    final uri = Uri.parse('$baseUrl/todos/${task.id}');
    final res = await http.put(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(task.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update task (code: ${res.statusCode})');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return Task.fromJson(decoded).copyWith(description: task.description);
  }

  Future<void> deleteTask(int id) async {
    final uri = Uri.parse('$baseUrl/todos/$id');
    final res = await http.delete(uri);

    if (res.statusCode != 200) {
      throw Exception('Failed to delete task (code: ${res.statusCode})');
    }
  }
}
