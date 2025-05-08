import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:checkme/models/user.dart';
import 'package:collection/collection.dart';

class UserService {
  static const String _filename = 'users.json';

  // Load users from local or asset
  static Future<List<User>> loadUsers() async {
    final file = await _getLocalFile();

    if (!(await file.exists())) {
      // Copy from asset on first run
      String assetData = await rootBundle.loadString('assets/data/users.json');
      await file.writeAsString(assetData);
    }

    final content = await file.readAsString();
    final List decoded = jsonDecode(content);
    return decoded.map((e) => User.fromJson(e)).toList();
  }

  static Future<void> saveUsers(List<User> users) async {
    final file = await _getLocalFile();
    final jsonString = jsonEncode(users.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonString);
  }

  // static Future<File> _getLocalFile() async {
  //   final dir = await getApplicationDocumentsDirectory();
  //   return File('${dir.path}/$_filename');
  // }

  static Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_filename');
    print('🗂️ User data file: ${file.path}');
    return file;
  }


  static Future<User?> findUserByEmail(String email) async {
    List<User> users = await loadUsers();
    return users.firstWhereOrNull((u) => u.email == email);
  }

  static Future<User?> findUser(String email, String password) async {
    List<User> users = await loadUsers();
    return users.firstWhereOrNull(
          (u) => u.email == email && u.password == password,
    );
  }

  static Future<void> addUser(User user) async {
    List<User> users = await loadUsers();
    users.add(user);
    await saveUsers(users);
  }
}
