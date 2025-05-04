class User {
  final String email;
  final String password;
  final String avatar;

  User({
    required this.email,
    required this.password,
    this.avatar = "assets/avatar.jpg",
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    email: json['email'],
    password: json['password'],
    avatar: json['avatar'] ?? "assets/avatar.jpg",
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'avatar': avatar,
  };
}
