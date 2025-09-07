class User {
  final String name;
  final String email;
  User({
    required this.name,
    required this.email,
  });

  // Para crear desde un Map (por ejemplo del AuthService)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  // Para convertir a Map (si quieres guardar o enviar datos)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }
}
