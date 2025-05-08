import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:checkme/models/todo.dart';

class TodoService {
  static const String _filename = 'todos.json';

  /// Get the local file for todos
  static Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_filename');
  }

  /// Load todos from local file or initialize from assets
  static Future<List<Todo>> loadTodos() async {
    final file = await _getLocalFile();

    // If the file doesn't exist, copy it from assets
    if (!(await file.exists())) {
      try {
        final assetData = await rootBundle.loadString('assets/data/todos.json');
        await file.writeAsString(assetData);
      } catch (e) {
        // Fallback if asset is missing
        await file.writeAsString(jsonEncode([]));
      }
    }

    final contents = await file.readAsString();
    if (contents.isEmpty) return [];

    final List decoded = jsonDecode(contents);
    return decoded.map((e) => Todo.fromJson(e)).toList();
  }

  /// Save todos to local file
  static Future<void> saveTodos(List<Todo> todos) async {
    final file = await _getLocalFile();
    final jsonData = jsonEncode(todos.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  /// Add a new todo
  static Future<void> addTodo(Todo newTodo) async {
    final todos = await loadTodos();
    todos.add(newTodo);
    await saveTodos(todos);
  }

  /// Update an existing todo
  static Future<void> updateTodo(Todo updatedTodo) async {
    final todos = await loadTodos();
    final index = todos.indexWhere((t) => t.createdAt == updatedTodo.createdAt);
    if (index != -1) {
      todos[index] = updatedTodo;
      await saveTodos(todos);
    }
  }

  /// Delete a todo
  static Future<void> deleteTodo(Todo todoToDelete) async {
    final todos = await loadTodos();
    todos.removeWhere((t) => t.createdAt == todoToDelete.createdAt);
    await saveTodos(todos);
  }

  /// Filter todos by category
  static Future<List<Todo>> filterByCategory(String category) async {
    final todos = await loadTodos();
    return todos.where((todo) => todo.category == category).toList();
  }

  /// Filter todos by search query (title or description)
  static Future<List<Todo>> searchTodos(String query) async {
    final todos = await loadTodos();
    return todos.where((todo) {
      final lowerQuery = query.toLowerCase();
      return todo.title.toLowerCase().contains(lowerQuery) ||
          (todo.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
