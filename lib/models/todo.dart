class Todo {
  String title;
  String? description;
  bool isDone;
  DateTime createdAt;

  Todo({
    required this.title,
    this.description,
    this.isDone = false,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      description: json['description'],
      isDone: json['isDone'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'isDone': isDone,
    'createdAt': createdAt.toIso8601String(),
  };
}
