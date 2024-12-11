class User {
  final String name;
  final String email;
  final String senha;

  const User({
    required this.name,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'senha': senha,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      email: json['email'] as String,
      senha: json['senha'] as String,
    );
  }
}
