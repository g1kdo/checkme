import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:checkme/ui/screens/login_screen.dart';
import 'package:checkme/services/todo_notifier.dart';
import 'package:checkme/services/database_service.dart';
import 'package:checkme/services/migration_service.dart';
import 'package:checkme/models/todo.dart';
import 'package:checkme/models/user.dart';

// Define a state notifier to manage theme state
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  // Method to toggle the theme
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  // Method to set the theme based on system preference
  void setSystemTheme() {
    state = ThemeMode.system;
  }
}

// Define a state notifier to manage current user state
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null);

  void setUser(User user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }
}

// Define the global provider for theme state
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// Define the global provider for user state
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

final todoProvider = StateNotifierProvider<TodoNotifier, List<Todo>>((ref) {
  return TodoNotifier();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database
  await DatabaseService.database;
  
  // Check if migration is needed and perform it
  try {
    if (await MigrationService.isMigrationNeeded()) {
      print('🔄 Migrating data from JSON to SQLite...');
      await MigrationService.migrateData();
    }
  } catch (e) {
    print('⚠️ Migration failed, continuing with fresh database: $e');
  }
  
  runApp(
    ProviderScope(
      child: CheckMeApp(),
    ),
  );
}


class CheckMeApp extends ConsumerWidget {
  const CheckMeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current theme mode from Riverpod provider
    final currentTheme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(), // Define dark theme
      themeMode: currentTheme, // Apply the current theme mode
      home: const LoginScreen(),
    );
  }
}