import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'checkme.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String usersTable = 'users';
  static const String todosTable = 'todos';

  // Users table columns
  static const String userIdColumn = 'id';
  static const String userEmailColumn = 'email';
  static const String userPasswordColumn = 'password';
  static const String userAvatarColumn = 'avatar';
  static const String userCreatedAtColumn = 'created_at';

  // Todos table columns
  static const String todoIdColumn = 'id';
  static const String todoTitleColumn = 'title';
  static const String todoDescriptionColumn = 'description';
  static const String todoIsDoneColumn = 'is_done';
  static const String todoCreatedAtColumn = 'created_at';
  static const String todoDueDateColumn = 'due_date';
  static const String todoCategoryColumn = 'category';
  static const String todoPriorityColumn = 'priority';
  static const String todoUserIdColumn = 'user_id';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $usersTable (
        $userIdColumn TEXT PRIMARY KEY,
        $userEmailColumn TEXT UNIQUE NOT NULL,
        $userPasswordColumn TEXT NOT NULL,
        $userAvatarColumn TEXT,
        $userCreatedAtColumn TEXT NOT NULL
      )
    ''');

    // Create todos table
    await db.execute('''
      CREATE TABLE $todosTable (
        $todoIdColumn TEXT PRIMARY KEY,
        $todoTitleColumn TEXT NOT NULL,
        $todoDescriptionColumn TEXT,
        $todoIsDoneColumn INTEGER NOT NULL DEFAULT 0,
        $todoCreatedAtColumn TEXT NOT NULL,
        $todoDueDateColumn TEXT,
        $todoCategoryColumn TEXT NOT NULL DEFAULT 'General',
        $todoPriorityColumn INTEGER NOT NULL DEFAULT 2,
        $todoUserIdColumn TEXT,
        FOREIGN KEY ($todoUserIdColumn) REFERENCES $usersTable ($userIdColumn)
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_todos_user_id ON $todosTable ($todoUserIdColumn)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_todos_category ON $todosTable ($todoCategoryColumn)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_todos_priority ON $todosTable ($todoPriorityColumn)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_todos_is_done ON $todosTable ($todoIsDoneColumn)
    ''');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Example: Add new columns or tables
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // Helper method to clear all data (for testing)
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(todosTable);
    await db.delete(usersTable);
  }
}
