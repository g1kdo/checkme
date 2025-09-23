import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:checkme/models/todo.dart';
import 'package:checkme/models/user.dart';
import 'package:checkme/services/database_service.dart';
import 'package:checkme/services/todo_service.dart';
import 'package:checkme/services/user_service.dart';

class MigrationService {
  static const _uuid = Uuid();

  /// Check if migration is needed (old JSON files exist)
  static Future<bool> isMigrationNeeded() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final todosFile = File('${directory.path}/todos.json');
      final usersFile = File('${directory.path}/users.json');
      
      return await todosFile.exists() || await usersFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Migrate data from JSON files to SQLite database
  static Future<void> migrateData() async {
    try {
      // Initialize database
      await DatabaseService.database;
      
      // Migrate users first
      await _migrateUsers();
      
      // Migrate todos
      await _migrateTodos();
      
      // Clean up old JSON files
      await _cleanupOldFiles();
      
      print('✅ Migration completed successfully');
    } catch (e) {
      print('❌ Migration failed: $e');
      rethrow;
    }
  }

  /// Migrate users from JSON to SQLite
  static Future<void> _migrateUsers() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final usersFile = File('${directory.path}/users.json');
      
      if (!await usersFile.exists()) {
        // Try to load from assets
        try {
          final assetData = await rootBundle.loadString('assets/data/users.json');
          await usersFile.writeAsString(assetData);
        } catch (e) {
          print('No users data found in assets');
          return;
        }
      }

      final content = await usersFile.readAsString();
      if (content.isEmpty) return;

      final List decoded = jsonDecode(content);
      final List<User> users = decoded.map((e) => User.fromJson(e)).toList();

      for (final user in users) {
        // Check if user already exists
        final existingUser = await UserService.findUserByEmail(user.email);
        if (existingUser == null) {
          // Create new user with ID
          final newUser = User(
            id: _uuid.v4(),
            email: user.email,
            password: user.password,
            avatar: user.avatar,
            createdAt: DateTime.now(),
          );
          await UserService.addUser(newUser);
          print('✅ Migrated user: ${user.email}');
        }
      }
    } catch (e) {
      print('❌ Failed to migrate users: $e');
    }
  }

  /// Migrate todos from JSON to SQLite
  static Future<void> _migrateTodos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final todosFile = File('${directory.path}/todos.json');
      
      if (!await todosFile.exists()) {
        // Try to load from assets
        try {
          final assetData = await rootBundle.loadString('assets/data/todos.json');
          await todosFile.writeAsString(assetData);
        } catch (e) {
          print('No todos data found in assets');
          return;
        }
      }

      final content = await todosFile.readAsString();
      if (content.isEmpty) return;

      final List decoded = jsonDecode(content);
      final List<Todo> todos = decoded.map((e) => Todo.fromJson(e)).toList();

      for (final todo in todos) {
        // Create new todo with ID and link to first user if available
        final users = await UserService.loadUsers();
        final userId = users.isNotEmpty ? users.first.id : null;
        
        final newTodo = Todo(
          id: _uuid.v4(),
          title: todo.title,
          description: todo.description,
          isDone: todo.isDone,
          createdAt: todo.createdAt,
          dueDate: todo.dueDate,
          category: todo.category,
          priority: todo.priority,
          userId: userId,
        );
        
        await TodoService.addTodo(newTodo);
        print('✅ Migrated todo: ${todo.title}');
      }
    } catch (e) {
      print('❌ Failed to migrate todos: $e');
    }
  }

  /// Clean up old JSON files after successful migration
  static Future<void> _cleanupOldFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final todosFile = File('${directory.path}/todos.json');
      final usersFile = File('${directory.path}/users.json');
      
      if (await todosFile.exists()) {
        await todosFile.delete();
        print('✅ Cleaned up old todos.json');
      }
      
      if (await usersFile.exists()) {
        await usersFile.delete();
        print('✅ Cleaned up old users.json');
      }
    } catch (e) {
      print('❌ Failed to cleanup old files: $e');
    }
  }

  /// Create sample data for new users
  static Future<void> createSampleData(String userId) async {
    try {
      final sampleTodos = [
        Todo(
          id: _uuid.v4(),
          title: 'Welcome to CheckMe!',
          description: 'This is your first todo. You can edit, complete, or delete it.',
          isDone: false,
          createdAt: DateTime.now(),
          category: 'General',
          priority: 2,
          userId: userId,
        ),
        Todo(
          id: _uuid.v4(),
          title: 'Explore the app features',
          description: 'Try creating new todos, setting priorities, and organizing by categories.',
          isDone: false,
          createdAt: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 1)),
          category: 'Personal',
          priority: 3,
          userId: userId,
        ),
        Todo(
          id: _uuid.v4(),
          title: 'Set up your first project',
          description: 'Create todos for your upcoming project and organize them by priority.',
          isDone: false,
          createdAt: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 3)),
          category: 'Work',
          priority: 4,
          userId: userId,
        ),
      ];

      for (final todo in sampleTodos) {
        await TodoService.addTodo(todo);
      }
      
      print('✅ Created sample data for new user');
    } catch (e) {
      print('❌ Failed to create sample data: $e');
    }
  }
}
