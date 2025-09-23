import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:checkme/models/todo.dart';
import 'package:checkme/services/todo_service.dart';

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);
  static const _uuid = Uuid();

  // Load todos from TodoService
  Future<void> loadTodos({String? userId}) async {
    final todos = await TodoService.loadTodos(userId: userId);
    state = todos;
  }

  // Add a new todo
  Future<String> addTodo(Todo todo) async {
    final todoId = await TodoService.addTodo(todo);
    await loadTodos(userId: todo.userId); // Reload todos after adding
    return todoId;
  }

  // Update a todo
  Future<void> updateTodo(Todo updatedTodo) async {
    await TodoService.updateTodo(updatedTodo);
    await loadTodos(userId: updatedTodo.userId); // Reload todos after updating
  }

  // Delete a todo
  Future<void> deleteTodo(String todoId, {String? userId}) async {
    await TodoService.deleteTodo(todoId);
    await loadTodos(userId: userId); // Reload todos after deleting
  }

  // Toggle todo completion status
  Future<void> toggleTodo(Todo todo) async {
    final updatedTodo = todo.copyWith(isDone: !todo.isDone);
    await updateTodo(updatedTodo);
  }

  // Filter todos by category
  Future<void> filterByCategory(String category, {String? userId}) async {
    final todos = await TodoService.filterByCategory(category, userId: userId);
    state = todos;
  }

  // Filter todos by priority
  Future<void> filterByPriority(int priority, {String? userId}) async {
    final todos = await TodoService.filterByPriority(priority, userId: userId);
    state = todos;
  }

  // Filter todos by status
  Future<void> filterByStatus(bool isDone, {String? userId}) async {
    final todos = await TodoService.filterByStatus(isDone, userId: userId);
    state = todos;
  }

  // Search todos
  Future<void> searchTodos(String query, {String? userId}) async {
    final todos = await TodoService.searchTodos(query, userId: userId);
    state = todos;
  }

  // Get upcoming todos
  Future<void> loadUpcomingTodos({String? userId}) async {
    final todos = await TodoService.getUpcomingTodos(userId: userId);
    state = todos;
  }

  // Get overdue todos
  Future<void> loadOverdueTodos({String? userId}) async {
    final todos = await TodoService.getOverdueTodos(userId: userId);
    state = todos;
  }

  // Get statistics
  Future<Map<String, int>> getStatistics({String? userId}) async {
    return await TodoService.getStatistics(userId: userId);
  }
}
