class User {
  final int id;
  final String name;
  final String email;
  final String? imagepathh;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.imagepathh,
  });

  // Para crear desde un Map (por ejemplo del AuthService)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imagepathh: map['imagepathh'] ?? "",
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
