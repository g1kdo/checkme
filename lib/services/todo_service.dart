import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:checkme/models/todo.dart';
import 'package:checkme/services/database_service.dart';

class TodoService {
  static const _uuid = Uuid();

  /// Load all todos for a specific user
  static Future<List<Todo>> loadTodos({String? userId}) async {
    final db = await DatabaseService.database;
    
    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoUserIdColumn} = ?',
        whereArgs: [userId],
        orderBy: '${DatabaseService.todoPriorityColumn} DESC, ${DatabaseService.todoCreatedAtColumn} DESC',
      );
    } else {
      maps = await db.query(
        DatabaseService.todosTable,
        orderBy: '${DatabaseService.todoPriorityColumn} DESC, ${DatabaseService.todoCreatedAtColumn} DESC',
      );
    }

    return maps.map((map) => _mapToTodo(map)).toList();
  }

  /// Add a new todo
  static Future<String> addTodo(Todo todo) async {
    final db = await DatabaseService.database;
    final todoId = _uuid.v4();
    
    final todoWithId = todo.copyWith(id: todoId);
    
    await db.insert(
      DatabaseService.todosTable,
      _todoToMap(todoWithId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return todoId;
  }

  /// Update an existing todo
  static Future<void> updateTodo(Todo todo) async {
    final db = await DatabaseService.database;
    
    await db.update(
      DatabaseService.todosTable,
      _todoToMap(todo),
      where: '${DatabaseService.todoIdColumn} = ?',
      whereArgs: [todo.id],
    );
  }

  /// Delete a todo
  static Future<void> deleteTodo(String todoId) async {
    final db = await DatabaseService.database;
    
    await db.delete(
      DatabaseService.todosTable,
      where: '${DatabaseService.todoIdColumn} = ?',
      whereArgs: [todoId],
    );
  }

  /// Get a todo by ID
  static Future<Todo?> getTodoById(String todoId) async {
    final db = await DatabaseService.database;
    
    final maps = await db.query(
      DatabaseService.todosTable,
      where: '${DatabaseService.todoIdColumn} = ?',
      whereArgs: [todoId],
    );

    if (maps.isNotEmpty) {
      return _mapToTodo(maps.first);
    }
    return null;
  }

  /// Filter todos by category
  static Future<List<Todo>> filterByCategory(String category, {String? userId}) async {
    final db = await DatabaseService.database;
    
    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoCategoryColumn} = ? AND ${DatabaseService.todoUserIdColumn} = ?',
        whereArgs: [category, userId],
        orderBy: '${DatabaseService.todoPriorityColumn} DESC, ${DatabaseService.todoCreatedAtColumn} DESC',
      );
    } else {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoCategoryColumn} = ?',
        whereArgs: [category],
        orderBy: '${DatabaseService.todoPriorityColumn} DESC, ${DatabaseService.todoCreatedAtColumn} DESC',
      );
    }

    return maps.map((map) => _mapToTodo(map)).toList();
  }

  /// Filter todos by priority
  static Future<List<Todo>> filterByPriority(int priority, {String? userId}) async {
    final db = await DatabaseService.database;
    
    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoPriorityColumn} = ? AND ${DatabaseService.todoUserIdColumn} = ?',
        whereArgs: [priority, userId],
        orderBy: '${DatabaseService.todoCreatedAtColumn} DESC',
      );
    } else {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoPriorityColumn} = ?',
        whereArgs: [priority],
        orderBy: '${DatabaseService.todoCreatedAtColumn} DESC',
      );
    }

    return maps.map((map) => _mapToTodo(map)).toList();
  }

  /// Filter todos by completion status
  static Future<List<Todo>> filterByStatus(bool isDone, {String? userId}) async {
    final db = await DatabaseService.database;
    
    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoIsDoneColumn} = ? AND ${DatabaseService.todoUserIdColumn} = ?',
        whereArgs: [isDone ? 1 : 0, userId],
        orderBy: '${DatabaseService.todoPriorityColumn} DESC, ${DatabaseService.todoCreatedAtColumn} DESC',
      );
    } else {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoIsDoneColumn} = ?',
        whereArgs: [isDone ? 1 : 0],
        orderBy: '${DatabaseService.todoPriorityColumn} DESC, ${DatabaseService.todoCreatedAtColumn} DESC',
      );
    }

    return maps.map((map) => _mapToTodo(map)).toList();
  }

  /// Search todos by title or description
  static Future<List<Todo>> searchTodos(String query, {String? userId}) async {
    final db = await DatabaseService.database;
    
    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '(${DatabaseService.todoTitleColumn} LIKE ? OR ${DatabaseService.todoDescriptionColumn} LIKE ?) AND ${DatabaseService.todoUserIdColumn} = ?',
        whereArgs: ['%$query%', '%$query%', userId],
        orderBy: '${DatabaseService.todoPriorityColumn} DESC, ${DatabaseService.todoCreatedAtColumn} DESC',
      );
    } else {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoTitleColumn} LIKE ? OR ${DatabaseService.todoDescriptionColumn} LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: '${DatabaseService.todoPriorityColumn} DESC, ${DatabaseService.todoCreatedAtColumn} DESC',
      );
    }

    return maps.map((map) => _mapToTodo(map)).toList();
  }

  /// Get todos with due dates approaching (within next 7 days)
  static Future<List<Todo>> getUpcomingTodos({String? userId}) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoDueDateColumn} IS NOT NULL AND ${DatabaseService.todoDueDateColumn} BETWEEN ? AND ? AND ${DatabaseService.todoIsDoneColumn} = 0 AND ${DatabaseService.todoUserIdColumn} = ?',
        whereArgs: [now.toIso8601String(), nextWeek.toIso8601String(), userId],
        orderBy: '${DatabaseService.todoDueDateColumn} ASC',
      );
    } else {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoDueDateColumn} IS NOT NULL AND ${DatabaseService.todoDueDateColumn} BETWEEN ? AND ? AND ${DatabaseService.todoIsDoneColumn} = 0',
        whereArgs: [now.toIso8601String(), nextWeek.toIso8601String()],
        orderBy: '${DatabaseService.todoDueDateColumn} ASC',
      );
    }

    return maps.map((map) => _mapToTodo(map)).toList();
  }

  /// Get overdue todos
  static Future<List<Todo>> getOverdueTodos({String? userId}) async {
    final db = await DatabaseService.database;
    final now = DateTime.now();
    
    List<Map<String, dynamic>> maps;
    if (userId != null) {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoDueDateColumn} IS NOT NULL AND ${DatabaseService.todoDueDateColumn} < ? AND ${DatabaseService.todoIsDoneColumn} = 0 AND ${DatabaseService.todoUserIdColumn} = ?',
        whereArgs: [now.toIso8601String(), userId],
        orderBy: '${DatabaseService.todoDueDateColumn} ASC',
      );
    } else {
      maps = await db.query(
        DatabaseService.todosTable,
        where: '${DatabaseService.todoDueDateColumn} IS NOT NULL AND ${DatabaseService.todoDueDateColumn} < ? AND ${DatabaseService.todoIsDoneColumn} = 0',
        whereArgs: [now.toIso8601String()],
        orderBy: '${DatabaseService.todoDueDateColumn} ASC',
      );
    }

    return maps.map((map) => _mapToTodo(map)).toList();
  }

  /// Get statistics for a user
  static Future<Map<String, int>> getStatistics({String? userId}) async {
    final db = await DatabaseService.database;
    
    String whereClause = userId != null ? 'WHERE ${DatabaseService.todoUserIdColumn} = ?' : '';
    List<dynamic> whereArgs = userId != null ? [userId] : [];
    
    // Total todos
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseService.todosTable} $whereClause',
      whereArgs,
    );
    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    
    // Completed todos
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseService.todosTable} $whereClause${whereClause.isNotEmpty ? ' AND' : ' WHERE'} ${DatabaseService.todoIsDoneColumn} = 1',
      whereArgs,
    );
    final completed = Sqflite.firstIntValue(completedResult) ?? 0;
    
    // Pending todos
    final pending = total - completed;
    
    // Overdue todos
    final now = DateTime.now();
    final overdueResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseService.todosTable} $whereClause${whereClause.isNotEmpty ? ' AND' : ' WHERE'} ${DatabaseService.todoDueDateColumn} IS NOT NULL AND ${DatabaseService.todoDueDateColumn} < ? AND ${DatabaseService.todoIsDoneColumn} = 0',
      [...whereArgs, now.toIso8601String()],
    );
    final overdue = Sqflite.firstIntValue(overdueResult) ?? 0;
    
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
    };
  }

  /// Convert Todo object to Map for database storage
  static Map<String, dynamic> _todoToMap(Todo todo) {
    return {
      DatabaseService.todoIdColumn: todo.id,
      DatabaseService.todoTitleColumn: todo.title,
      DatabaseService.todoDescriptionColumn: todo.description,
      DatabaseService.todoIsDoneColumn: todo.isDone ? 1 : 0,
      DatabaseService.todoCreatedAtColumn: todo.createdAt.toIso8601String(),
      DatabaseService.todoDueDateColumn: todo.dueDate?.toIso8601String(),
      DatabaseService.todoCategoryColumn: todo.category,
      DatabaseService.todoPriorityColumn: todo.priority,
      DatabaseService.todoUserIdColumn: todo.userId,
    };
  }

  /// Convert Map from database to Todo object
  static Todo _mapToTodo(Map<String, dynamic> map) {
    return Todo(
      id: map[DatabaseService.todoIdColumn],
      title: map[DatabaseService.todoTitleColumn],
      description: map[DatabaseService.todoDescriptionColumn],
      isDone: map[DatabaseService.todoIsDoneColumn] == 1,
      createdAt: DateTime.parse(map[DatabaseService.todoCreatedAtColumn]),
      dueDate: map[DatabaseService.todoDueDateColumn] != null 
          ? DateTime.parse(map[DatabaseService.todoDueDateColumn]) 
          : null,
      category: map[DatabaseService.todoCategoryColumn],
      priority: map[DatabaseService.todoPriorityColumn],
      userId: map[DatabaseService.todoUserIdColumn],
    );
  }
}
