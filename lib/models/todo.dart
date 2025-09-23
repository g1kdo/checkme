class Todo {
  String id;
  String title;
  String? description;
  bool isDone;
  DateTime createdAt;
  DateTime? dueDate;
  String category;
  int priority; // 1 = Low, 2 = Medium, 3 = High, 4 = Urgent
  String? userId; // Link to user

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.category = 'General',
    this.priority = 2, // Default to Medium priority
    this.userId,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      category: json['category'] ?? 'General',
      isDone: json['isDone'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] ?? 2,
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority,
    'userId': userId,
  };

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isDone,
    DateTime? createdAt,
    DateTime? dueDate,
    int? priority,
    String? userId,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
    );
  }

  // Helper methods for priority
  String get priorityText {
    switch (priority) {
      case 1: return 'Low';
      case 2: return 'Medium';
      case 3: return 'High';
      case 4: return 'Urgent';
      default: return 'Medium';
    }
  }

  // Helper method to get priority color
  int get priorityColor {
    switch (priority) {
      case 1: return 0xFF4CAF50; // Green
      case 2: return 0xFF2196F3; // Blue
      case 3: return 0xFFFF9800; // Orange
      case 4: return 0xFFF44336; // Red
      default: return 0xFF2196F3; // Blue
    }
  }
}
