import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../main.dart';
import '../../models/todo.dart';
import '../../models/user.dart';
import '../../services/todo_service.dart';
import '../../services/user_service.dart';
import '../../services/export_service.dart';
import 'todo_details_screen.dart';
import 'login_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final User user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  DateTime? selectedDueDate;
  String selectedCategory = 'All';
  String searchQuery = '';
  String selectedStatus = 'All';
  int selectedPriority = 0; // 0 = All, 1-4 = Priority levels
  bool isGridView = false;
  bool isLoading = false;
  
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<String> categories = ['All', 'General', 'Work', 'Personal', 'Shopping', 'Health', 'Education'];
  final List<String> statuses = ['All', 'Pending', 'Completed'];
  final List<String> priorities = ['All', 'Low', 'Medium', 'High', 'Urgent'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    
    // Load todos when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadTodos();
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() => isLoading = true);
    await ref.read(todoProvider.notifier).loadTodos(userId: widget.user.id);
    setState(() => isLoading = false);
  }

  // Filter todos based on current filters
  List<Todo> _filterTodos(List<Todo> todos) {
    List<Todo> filteredTodos = todos.where((todo) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!todo.title.toLowerCase().contains(query) &&
            !(todo.description?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Category filter
      if (selectedCategory != 'All' && todo.category != selectedCategory) {
        return false;
      }

      // Status filter
      if (selectedStatus != 'All') {
        final isCompleted = selectedStatus == 'Completed';
        if (todo.isDone != isCompleted) {
          return false;
        }
      }

      // Priority filter
      if (selectedPriority != 0 && todo.priority != selectedPriority) {
        return false;
      }

      return true;
    }).toList();

    // Sort by priority and due date
    filteredTodos.sort((a, b) {
      // First sort by completion status (pending first)
      if (a.isDone != b.isDone) {
        return a.isDone ? 1 : -1;
      }
      
      // Then by priority (higher priority first)
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      
      // Then by due date (earlier due date first)
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      
      // Finally by creation date (newer first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return filteredTodos;
  }

  Future<void> _addTodo(String title, String? description, DateTime? dueDate, String category, int priority) async {
    final todo = Todo(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      category: category,
      priority: priority,
      userId: widget.user.id,
    );
    
    await ref.read(todoProvider.notifier).addTodo(todo);
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrentPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setDialogState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNewPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setDialogState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final currentPassword = currentPasswordController.text.trim();
                  final newPassword = newPasswordController.text.trim();
                  final confirmPassword = confirmPasswordController.text.trim();

                  // Validation
                  if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (currentPassword != widget.user.password) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Current password is incorrect'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (newPassword.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New password must be at least 6 characters'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (newPassword != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('New passwords do not match'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Update password
                  final updatedUser = widget.user.copyWith(password: newPassword);
                  await UserService.updateUser(updatedUser);
                  
                  // Update user in state
                  ref.read(userProvider.notifier).setUser(updatedUser);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Change Password'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTodoDialog() {
    String title = '';
    String? description;
    String category = 'General';
    int priority = 2; // Medium priority
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Todo'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => title = value,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) => description = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: categories.skip(1).map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          )).toList(),
                          onChanged: (value) => category = value!,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: priority,
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: 1, child: Text('Low', style: TextStyle(color: Color(0xFF4CAF50)))),
                            DropdownMenuItem(value: 2, child: Text('Medium', style: TextStyle(color: Color(0xFF2196F3)))),
                            DropdownMenuItem(value: 3, child: Text('High', style: TextStyle(color: Color(0xFFFF9800)))),
                            DropdownMenuItem(value: 4, child: Text('Urgent', style: TextStyle(color: Color(0xFFF44336)))),
                          ],
                          onChanged: (value) => priority = value!,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setDialogState(() => dueDate = pickedDate);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(dueDate == null 
                              ? 'Select Due Date (optional)' 
                              : 'Due: ${DateFormat('MMM dd, yyyy').format(dueDate!)}'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (title.isNotEmpty) {
                    _addTodo(title, description, dueDate, category, priority);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Todo'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodoCard(Todo todo) {
    final isOverdue = todo.dueDate != null && 
                     todo.dueDate!.isBefore(DateTime.now()) && 
                     !todo.isDone;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TodoDetailsScreen(
                todo: todo,
                onUpdateTodo: (updatedTodo) async {
                  await ref.read(todoProvider.notifier).updateTodo(updatedTodo);
                },
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(
                width: 4,
                color: Color(todo.priorityColor),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: todo.isDone,
                    onChanged: (_) async {
                      await ref.read(todoProvider.notifier).toggleTodo(todo);
                    },
                  ),
                  Expanded(
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: todo.isDone ? TextDecoration.lineThrough : null,
                        color: todo.isDone ? Colors.grey : null,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await ref.read(todoProvider.notifier).deleteTodo(todo.id, userId: widget.user.id);
                      }
                    },
                  ),
                ],
              ),
              if (todo.description?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  todo.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(todo.priorityColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      todo.priorityText,
                      style: TextStyle(
                        color: Color(todo.priorityColor),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      todo.category,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (todo.dueDate != null)
                    Text(
                      DateFormat('MMM dd').format(todo.dueDate!),
                      style: TextStyle(
                        color: isOverdue ? Colors.red : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: isOverdue ? FontWeight.bold : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos) {
    if (isGridView) {
      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: todos.length,
        itemBuilder: (context, index) => _buildTodoCard(todos[index]),
      );
    } else {
      return ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) => _buildTodoCard(todos[index]),
      );
    }
  }

  Widget _buildStatistics() {
    return FutureBuilder<Map<String, int>>(
      future: ref.read(todoProvider.notifier).getStatistics(userId: widget.user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final stats = snapshot.data!;
        final completionRate = stats['total']! > 0 
            ? (stats['completed']! / stats['total']! * 100).round() 
            : 0;
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      stats['total']!.toString(),
                      Icons.list_alt,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      stats['completed']!.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Pending',
                      stats['pending']!.toString(),
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Overdue',
                      stats['overdue']!.toString(),
                      Icons.warning,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: completionRate / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  completionRate == 100 ? Colors.green : Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completion Rate: $completionRate%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeProvider.notifier);
    final currentTheme = ref.watch(themeProvider);
    final todos = ref.watch(todoProvider);
    final filteredTodos = _filterTodos(todos);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.user.email.split('@')[0]}!'),
        actions: [
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => isGridView = !isGridView);
            },
          ),
          IconButton(
            icon: Icon(currentTheme == ThemeMode.dark ? Icons.brightness_7 : Icons.brightness_6),
            onPressed: () => themeNotifier.toggleTheme(),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              PopupMenuItem(
                value: 'change_password',
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Change Password'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export_json',
                child: const Row(
                  children: [
                    Icon(Icons.download, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Export as JSON'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'export_csv',
                child: const Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Export as CSV'),
                  ],
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'change_password') {
                _showChangePasswordDialog();
              } else if (value == 'export_json') {
                try {
                  final filePath = await ExportService.exportToJson(userId: widget.user.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Todos exported to: $filePath'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Export failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else if (value == 'export_csv') {
                try {
                  final filePath = await ExportService.exportToCsv(userId: widget.user.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Todos exported to: $filePath'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Export failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else if (value == 'logout') {
                ref.read(userProvider.notifier).clearUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.list), text: 'All Todos'),
            Tab(icon: Icon(Icons.pending), text: 'Pending'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Dashboard Tab
          Column(
            children: [
              _buildStatistics(),
              const Divider(),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search Todos',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (value) {
                          setState(() => searchQuery = value);
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildTodoList(filteredTodos),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // All Todos Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search Todos',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
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
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: selectedPriority,
                            decoration: const InputDecoration(
                              labelText: 'Priority',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(value: 0, child: Text('All')),
                              DropdownMenuItem(value: 1, child: Text('Low')),
                              DropdownMenuItem(value: 2, child: Text('Medium')),
                              DropdownMenuItem(value: 3, child: Text('High')),
                              DropdownMenuItem(value: 4, child: Text('Urgent')),
                            ],
                            onChanged: (value) {
                              setState(() => selectedPriority = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTodoList(filteredTodos),
              ),
            ],
          ),
          // Pending Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Pending Todos',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                ),
              ),
              Expanded(
                child: isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTodoList(filteredTodos.where((todo) => !todo.isDone).toList()),
              ),
            ],
          ),
          // Completed Tab
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Completed Todos',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => searchQuery = value);
                  },
                ),
              ),
              Expanded(
                child: isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _buildTodoList(filteredTodos.where((todo) => todo.isDone).toList()),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _showAddTodoDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Todo'),
        ),
      ),
    );
  }
}