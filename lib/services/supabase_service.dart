import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'tasks';

  Future<List<Task>> getTasks() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .order('date', ascending: true);

      return (response as List).map((data) => Task.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      return [];
    }
  }

  Future<void> addTask(Task task) async {
    try {
      await _client.from(_tableName).insert(task.toJson());
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  Future<void> updateTaskStatus(String id, bool isCompleted) async {
    try {
      await _client
          .from(_tableName)
          .update({'is_completed': isCompleted})
          .eq('id', id);
    } catch (e) {
      debugPrint('Error updating task status: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      if (task.id == null) return;
      await _client
          .from(_tableName)
          .update(task.toJson())
          .eq('id', task.id!);
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _client.from(_tableName).delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }
}
