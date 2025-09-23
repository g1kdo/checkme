import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:checkme/models/user.dart';
import 'package:checkme/services/database_service.dart';

class UserService {
  static const _uuid = Uuid();

  /// Load all users
  static Future<List<User>> loadUsers() async {
    final db = await DatabaseService.database;
    
    final maps = await db.query(
      DatabaseService.usersTable,
      orderBy: '${DatabaseService.userCreatedAtColumn} DESC',
    );

    return maps.map((map) => _mapToUser(map)).toList();
  }

  /// Find user by email
  static Future<User?> findUserByEmail(String email) async {
    final db = await DatabaseService.database;
    
    final maps = await db.query(
      DatabaseService.usersTable,
      where: '${DatabaseService.userEmailColumn} = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  /// Find user by email and password
  static Future<User?> findUser(String email, String password) async {
    final db = await DatabaseService.database;
    
    final maps = await db.query(
      DatabaseService.usersTable,
      where: '${DatabaseService.userEmailColumn} = ? AND ${DatabaseService.userPasswordColumn} = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  /// Add a new user
  static Future<String> addUser(User user) async {
    final db = await DatabaseService.database;
    final userId = _uuid.v4();
    
    final userWithId = User(
      id: userId,
      email: user.email,
      password: user.password,
      avatar: user.avatar,
      createdAt: DateTime.now(),
    );
    
    await db.insert(
      DatabaseService.usersTable,
      _userToMap(userWithId),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return userId;
  }

  /// Update an existing user
  static Future<void> updateUser(User user) async {
    final db = await DatabaseService.database;
    
    await db.update(
      DatabaseService.usersTable,
      _userToMap(user),
      where: '${DatabaseService.userIdColumn} = ?',
      whereArgs: [user.id],
    );
  }

  /// Delete a user
  static Future<void> deleteUser(String userId) async {
    final db = await DatabaseService.database;
    
    // First delete all todos associated with this user
    await db.delete(
      DatabaseService.todosTable,
      where: '${DatabaseService.todoUserIdColumn} = ?',
      whereArgs: [userId],
    );
    
    // Then delete the user
    await db.delete(
      DatabaseService.usersTable,
      where: '${DatabaseService.userIdColumn} = ?',
      whereArgs: [userId],
    );
  }

  /// Get user by ID
  static Future<User?> getUserById(String userId) async {
    final db = await DatabaseService.database;
    
    final maps = await db.query(
      DatabaseService.usersTable,
      where: '${DatabaseService.userIdColumn} = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return _mapToUser(maps.first);
    }
    return null;
  }

  /// Check if email already exists
  static Future<bool> emailExists(String email) async {
    final user = await findUserByEmail(email);
    return user != null;
  }

  /// Convert User object to Map for database storage
  static Map<String, dynamic> _userToMap(User user) {
    return {
      DatabaseService.userIdColumn: user.id,
      DatabaseService.userEmailColumn: user.email,
      DatabaseService.userPasswordColumn: user.password,
      DatabaseService.userAvatarColumn: user.avatar,
      DatabaseService.userCreatedAtColumn: user.createdAt.toIso8601String(),
    };
  }

  /// Convert Map from database to User object
  static User _mapToUser(Map<String, dynamic> map) {
    return User(
      id: map[DatabaseService.userIdColumn],
      email: map[DatabaseService.userEmailColumn],
      password: map[DatabaseService.userPasswordColumn],
      avatar: map[DatabaseService.userAvatarColumn],
      createdAt: DateTime.parse(map[DatabaseService.userCreatedAtColumn]),
    );
  }
}
