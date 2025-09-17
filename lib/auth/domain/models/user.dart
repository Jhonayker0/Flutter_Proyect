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
      name: map['name'] ?? map['nombre'] ?? '',
      email: map['email'] ?? map['correo'] ?? '',
      imagepathh: map['imagepathh'] ?? map['imagen'] ?? "",
    );
  }

  // Para crear desde JSON de la API ROBLE
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['nombre'] ?? '',
      email: json['email'] ?? json['correo'] ?? '',
      imagepathh: json['image'] ?? json['imagen'] ?? json['imagepathh'],
    );
  }

  // Para convertir a Map (si quieres guardar o enviar datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imagepathh': imagepathh,
    };
  }

  // Para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': imagepathh,
    };
  }

  // Método copyWith para crear copias modificadas
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? imagepathh,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imagepathh: imagepathh ?? this.imagepathh,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, imagepathh: $imagepathh)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.imagepathh == imagepathh;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        imagepathh.hashCode;
  }
}







