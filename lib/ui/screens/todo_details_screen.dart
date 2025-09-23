import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:checkme/models/todo.dart';

class TodoDetailsScreen extends StatefulWidget {
  final Todo todo;
  final Function(Todo) onUpdateTodo;

  const TodoDetailsScreen({
    super.key,
    required this.todo,
    required this.onUpdateTodo,
  });

  @override
  State<TodoDetailsScreen> createState() => _TodoDetailsScreenState();
}

class _TodoDetailsScreenState extends State<TodoDetailsScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime? selectedDueDate;
  late String selectedCategory;
  late int selectedPriority;
  late bool isDone;

  final List<String> categories = ['General', 'Work', 'Personal', 'Shopping', 'Health', 'Education'];
  final List<String> priorities = ['Low', 'Medium', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.todo.title);
    descriptionController = TextEditingController(text: widget.todo.description ?? '');
    selectedDueDate = widget.todo.dueDate;
    selectedCategory = widget.todo.category;
    selectedPriority = widget.todo.priority;
    isDone = widget.todo.isDone;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveTodo() async {
    final updatedTodo = widget.todo.copyWith(
      title: titleController.text,
      description: descriptionController.text,
      dueDate: selectedDueDate,
      category: selectedCategory,
      priority: selectedPriority,
      isDone: isDone,
    );
    widget.onUpdateTodo(updatedTodo);
    Navigator.pop(context);
  }

  void _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => selectedDueDate = pickedDate);
    }
  }

  void _clearDueDate() {
    setState(() => selectedDueDate = null);
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return const Color(0xFF4CAF50); // Green
      case 2: return const Color(0xFF2196F3); // Blue
      case 3: return const Color(0xFFFF9800); // Orange
      case 4: return const Color(0xFFF44336); // Red
      default: return const Color(0xFF2196F3); // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = selectedDueDate != null && 
                     selectedDueDate!.isBefore(DateTime.now()) && 
                     !isDone;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Checkbox(
                      value: isDone,
                      onChanged: (value) {
                        setState(() => isDone = value ?? false);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isDone ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDone ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Priority and Category Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Low'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Medium'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF9800),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('High'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 4,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF44336),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Urgent'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedPriority = value!);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: categories.map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    )).toList(),
                    onChanged: (value) {
                      setState(() => selectedCategory = value!);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Due Date
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Due Date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: isOverdue ? Colors.red : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: _selectDueDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                selectedDueDate == null
                                    ? 'No due date set'
                                    : DateFormat('MMM dd, yyyy').format(selectedDueDate!),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isOverdue ? Colors.red : Colors.black,
                                  fontWeight: isOverdue ? FontWeight.bold : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (selectedDueDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearDueDate,
                          ),
                      ],
                    ),
                    if (isOverdue)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          '⚠️ This todo is overdue!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Created Date
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey),
                    const SizedBox(width: 8),
                    const Text('Created: '),
                    Text(
                      DateFormat('MMM dd, yyyy at hh:mm a').format(widget.todo.createdAt),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saveTodo,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
