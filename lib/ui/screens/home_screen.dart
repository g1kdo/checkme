import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../models/todo.dart';
import '../../services/todo_service.dart';
import 'todo_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String userName;
  final String userAvatar;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load todos when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(todoProvider.notifier).loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final currentTheme = ref.watch(themeProvider);

    DateTime? selectedDueDate;
    String selectedCategory = 'General';
    String searchQuery = '';

    // Add a new todo with a due date and category
    void _addTodo(String title, String? description, DateTime? dueDate, String category) async {
      Todo newTodo = Todo(
        title: title,
        description: description,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        category: category,
      );
      await ref.read(todoProvider.notifier).addTodo(newTodo);
    }

    // Search logic
    List<Todo> _filterTodos(List<Todo> todos) {
      return todos.where((todo) {
        final query = searchQuery.toLowerCase();
        return todo.title.toLowerCase().contains(query) ||
            (todo.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Show Add Todo dialog
    void _showAddTodoDialog() {
      String title = '';
      String? description;

      void _selectDueDate() async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null && pickedDate != selectedDueDate) {
          selectedDueDate = pickedDate;
        }
      }

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Todo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: 'Todo Title'),
                  onChanged: (value) => title = value,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: 'Description (optional)'),
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectDueDate,
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      const SizedBox(width: 8),
                      Text(selectedDueDate == null
                          ? 'Select Due Date'
                          : 'Due: ${selectedDueDate!.toLocal()}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedCategory,
                  onChanged: (newCategory) {
                    if (newCategory != null) {
                      selectedCategory = newCategory;
                    }
                  },
                  items: <String>['General', 'School', 'Personal', 'Urgent']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (title.isNotEmpty) {
                    _addTodo(title, description, selectedDueDate, selectedCategory);
                    Navigator.pop(context); // Close dialog
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Dashboard'),
        actions: [
          IconButton(
            icon: Icon(currentTheme == ThemeMode.dark ? Icons.brightness_7 : Icons.brightness_6),
            onPressed: () => themeNotifier.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(widget.userAvatar),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Text(
                  'Welcome, ${widget.userName}!',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer(
                builder: (context, watch, _) {
                  final todos = ref.watch(todoProvider);

                  return ListView.builder(
                    itemCount: _filterTodos(todos).length,
                    itemBuilder: (context, index) {
                      final todo = _filterTodos(todos)[index];

                      // Show "Overdue" if the due date has passed
                      String overdueLabel = '';
                      if (todo.dueDate != null &&
                          todo.dueDate!.isBefore(DateTime.now()) &&
                          !todo.isDone) {
                        overdueLabel = ' - Overdue';
                      }

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodoDetailsScreen(
                                todo: todo,
                                onUpdateTodo: (Todo updatedTodo) async {
                                  await ref.read(todoProvider.notifier).updateTodo(updatedTodo);
                                },
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: Checkbox(
                            value: todo.isDone,
                            onChanged: (_) async {
                              todo.isDone = !todo.isDone;
                              await ref.read(todoProvider.notifier).updateTodo(todo);
                            },
                          ),
                          title: Text(todo.title + overdueLabel),
                          subtitle: Text(todo.category),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              await ref.read(todoProvider.notifier).deleteTodo(todo);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
