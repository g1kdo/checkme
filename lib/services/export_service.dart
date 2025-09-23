import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:checkme/models/todo.dart';
import 'package:checkme/services/todo_service.dart';

class ExportService {
  /// Export todos to JSON file
  static Future<String> exportToJson({String? userId}) async {
    try {
      final todos = await TodoService.loadTodos(userId: userId);
      final jsonData = jsonEncode(todos.map((todo) => todo.toJson()).toList());
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'checkme_todos_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonData);
      return file.path;
    } catch (e) {
      throw Exception('Failed to export todos: $e');
    }
  }

  /// Export todos to CSV format
  static Future<String> exportToCsv({String? userId}) async {
    try {
      final todos = await TodoService.loadTodos(userId: userId);
      
      final csvData = StringBuffer();
      csvData.writeln('Title,Description,Category,Priority,Status,Due Date,Created Date');
      
      for (final todo in todos) {
        csvData.writeln([
          '"${todo.title.replaceAll('"', '""')}"',
          '"${(todo.description ?? '').replaceAll('"', '""')}"',
          '"${todo.category}"',
          '"${todo.priorityText}"',
          '"${todo.isDone ? 'Completed' : 'Pending'}"',
          '"${todo.dueDate?.toIso8601String() ?? ''}"',
          '"${todo.createdAt.toIso8601String()}"',
        ].join(','));
      }
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'checkme_todos_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(csvData.toString());
      return file.path;
    } catch (e) {
      throw Exception('Failed to export todos: $e');
    }
  }

  /// Get export statistics
  static Future<Map<String, dynamic>> getExportStats({String? userId}) async {
    try {
      final todos = await TodoService.loadTodos(userId: userId);
      final stats = await TodoService.getStatistics(userId: userId);
      
      return {
        'totalTodos': todos.length,
        'completedTodos': stats['completed'],
        'pendingTodos': stats['pending'],
        'overdueTodos': stats['overdue'],
        'categories': todos.map((todo) => todo.category).toSet().toList(),
        'priorities': todos.map((todo) => todo.priorityText).toSet().toList(),
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get export stats: $e');
    }
  }
}
