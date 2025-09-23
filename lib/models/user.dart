class User {
  final String id;
  final String email;
  final String password;
  final String avatar;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.password,
    this.avatar = "assets/avatar.jpg",
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? '',
    email: json['email'],
    password: json['password'],
    avatar: json['avatar'] ?? "assets/avatar.jpg",
    createdAt: json['createdAt'] != null 
        ? DateTime.parse(json['createdAt']) 
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'password': password,
    'avatar': avatar,
    'createdAt': createdAt.toIso8601String(),
  };

  User copyWith({
    String? id,
    String? email,
    String? password,
    String? avatar,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
