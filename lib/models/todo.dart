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
}