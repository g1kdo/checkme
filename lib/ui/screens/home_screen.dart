import 'package:flutter/material.dart';
import 'todo_details_screen.dart';
import 'package:checkme/models/todo.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Todo> _todos = [];
  String _filter = 'ALL'; // Default filter is 'ALL'

  // Method to filter tasks based on the selected filter
  List<Todo> getFilteredTodos() {
    if (_filter == 'PENDING') {
      return _todos.where((todo) => !todo.isDone).toList();
    } else if (_filter == 'COMPLETED') {
      return _todos.where((todo) => todo.isDone).toList();
    }
    return _todos; // 'ALL' filter shows all tasks
  }

  // Add a new todo
  void _addTodo(String title, String? description) {
    setState(() {
      _todos.add(Todo(
        title: title,
        description: description,
        createdAt: DateTime.now(),
      ));
    });
  }

  // Update a todo
  void _updateTodo(Todo updatedTodo) {
    setState(() {
      _todos[_todos.indexWhere((todo) => todo.createdAt == updatedTodo.createdAt)] = updatedTodo;
    });
  }

  // Toggle the completion status of a todo
  void _toggleTodo(Todo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
  }

  // Delete a todo
  void _deleteTodo(Todo todo) {
    setState(() {
      _todos.remove(todo);
    });
  }

  // Show the Add Todo dialog
  void _showAddTodoDialog() {
    String title = '';
    String? description;

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
                  _addTodo(title, description);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Dashboard'),
        actions: [
          // PopupMenuButton for filtering tasks
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'ALL',
                child: Text('All Tasks'),
              ),
              const PopupMenuItem<String>(
                value: 'PENDING',
                child: Text('Pending Tasks'),
              ),
              const PopupMenuItem<String>(
                value: 'COMPLETED',
                child: Text('Completed Tasks'),
              ),
            ],
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
              child: ListView.builder(
                itemCount: getFilteredTodos().length,  // Use filtered todos
                itemBuilder: (context, index) {
                  final todo = getFilteredTodos()[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to TodoDetailsScreen and pass the update function
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TodoDetailsScreen(
                            todo: todo,
                            onUpdateTodo: _updateTodo, // Pass the update function
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Checkbox(
                        value: todo.isDone,
                        onChanged: (_) => _toggleTodo(todo),
                      ),
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                          color: todo.isDone ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTodo(todo),
                      ),
                    ),
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
