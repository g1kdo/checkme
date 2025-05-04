import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:checkme/models/todo.dart';

class TodoDetailsScreen extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onUpdateTodo; // Function to handle updating the todo

  const TodoDetailsScreen({
    super.key,
    required this.todo,
    required this.onUpdateTodo, // Initialize the update function
  });

  @override
  _TodoDetailsScreenState createState() => _TodoDetailsScreenState();
}

class _TodoDetailsScreenState extends State<TodoDetailsScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Show the Edit Todo dialog
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Enter todo title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Enter description (optional)'),
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
                if (_titleController.text.isNotEmpty) {
                  widget.onUpdateTodo(
                    Todo(
                      title: _titleController.text,
                      description: _descriptionController.text.isEmpty
                          ? null
                          : _descriptionController.text,
                      createdAt: widget.todo.createdAt,
                    ),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to HomeScreen after editing
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
        title: const Text('Todo Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDialog, // Show the edit dialog on press
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.todo.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Created at: ${DateFormat('yyyy-MM-dd HH:mm').format(widget.todo.createdAt)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            if (widget.todo.description != null && widget.todo.description!.isNotEmpty)
              Text(
                'Description: ${widget.todo.description}',
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
