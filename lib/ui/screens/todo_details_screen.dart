import 'package:flutter/material.dart';
import 'package:checkme/models/todo.dart';
import 'package:checkme/services/todo_service.dart';

class TodoDetailsScreen extends StatelessWidget {
  final Todo todo;
  final Function(Todo) onUpdateTodo;

  const TodoDetailsScreen({
    super.key,
    required this.todo,
    required this.onUpdateTodo,
  });

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.description ?? '');
    DateTime? selectedDueDate = todo.dueDate;
    String selectedCategory = todo.category;

    void _saveTodo() async {
      final updatedTodo = todo.copyWith(
        title: titleController.text,
        description: descriptionController.text,
        dueDate: selectedDueDate,
        category: selectedCategory,
      );
      await TodoService.updateTodo(updatedTodo);
      onUpdateTodo(updatedTodo);
      Navigator.pop(context); // Return to home screen
    }

    void _selectDueDate() async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDueDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null && pickedDate != selectedDueDate) {
        selectedDueDate = pickedDate;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTodo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTodo,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
