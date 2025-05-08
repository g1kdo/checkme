class Todo {
  String title;
  String? description;
  bool isDone;
  DateTime createdAt;
  DateTime? dueDate;
  String category; // Add this field

  Todo({
    required this.title,
    this.description,
    this.isDone = false,
    required this.createdAt,
    this.dueDate,
    this.category = 'General', // Default category
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'] ?? '', // If 'title' is null, set an empty string
      description: json['description'],
      category: json['category'] ?? 'General', // Default to 'General' if 'category' is null
      isDone: json['isDone'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'category': category,
    'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
  };

  Todo copyWith({
    String? title,
    String? description,
    String? category,
    bool? isDone,
    DateTime? createdAt,
    DateTime? dueDate,
  }) {
    return Todo(
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
