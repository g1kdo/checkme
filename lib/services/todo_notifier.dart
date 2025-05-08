import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/models/todo.dart';
import 'package:checkme/services/todo_service.dart';

class TodoNotifier extends StateNotifier<List<Todo>> {
  TodoNotifier() : super([]);

  // Load todos from TodoService
  Future<void> loadTodos() async {
    final todos = await TodoService.loadTodos();
    state = todos;
  }

  // Add a new todo
  Future<void> addTodo(Todo todo) async {
    await TodoService.addTodo(todo);
    await loadTodos(); // Reload todos after adding
  }

  // Update a todo
  Future<void> updateTodo(Todo updatedTodo) async {
    await TodoService.updateTodo(updatedTodo);
    await loadTodos(); // Reload todos after updating
  }

  // Delete a todo
  Future<void> deleteTodo(Todo todo) async {
    await TodoService.deleteTodo(todo);
    await loadTodos(); // Reload todos after deleting
  }
}
