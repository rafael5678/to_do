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

  Future<List<Task>> getSavedTasks() async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('is_saved', true)
          .order('date', ascending: true);

      return (response as List).map((data) => Task.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error fetching saved tasks: $e');
      return [];
    }
  }

  Future<String?> uploadFile(String fileName, dynamic fileData) async {
    try {
      final path = 'uploads/$fileName';
      await _client.storage.from('task-files').uploadBinary(path, fileData);
      return _client.storage.from('task-files').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
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
      await _client.from(_tableName).update(task.toJson()).eq('id', task.id!);
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> toggleSaveTask(String id, bool isSaved) async {
    try {
      await _client.from(_tableName).update({'is_saved': isSaved}).eq('id', id);
    } catch (e) {
      debugPrint('Error toggling save status: $e');
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
