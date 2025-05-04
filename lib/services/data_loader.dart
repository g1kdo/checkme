import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:checkme/models/todo.dart';
import 'package:checkme/models/user.dart';

class DataLoader {
  static Future<List<Todo>> loadTodos() async {
    final String jsonStr = await rootBundle.loadString('assets/data/todos.json');
    final List data = jsonDecode(jsonStr);
    return data.map((e) => Todo.fromJson(e)).toList();
  }

  static Future<List<User>> loadUsers() async {
    final String jsonStr = await rootBundle.loadString('assets/data/users.json');
    final List data = jsonDecode(jsonStr);
    return data.map((e) => User.fromJson(e)).toList();
  }
}
