class User {
  final int id; // Volvemos a int pero lo calculamos desde String UUID
  final String name;
  final String email;
  final String? imagepathh;
  final String? uuid; // Guardamos el UUID original

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.imagepathh,
    this.uuid,
  });

  // Para crear desde un Map (por ejemplo del AuthService)
  factory User.fromMap(Map<String, dynamic> map) {
    final idValue = map['id'];
    int finalId;
    String? uuidValue;

    if (idValue is String) {
      // Si es String (UUID), calcular hash como int y guardar UUID
      uuidValue = idValue;
      finalId = idValue.hashCode.abs();
    } else if (idValue is int) {
      finalId = idValue;
    } else {
      finalId = 0;
    }

    return User(
      id: finalId,
      name: map['name'] ?? map['nombre'] ?? '',
      email: map['email'] ?? map['correo'] ?? '',
      imagepathh: map['imagepathh'] ?? map['imagen'] ?? "",
      uuid: uuidValue,
    );
  }

  // Para crear desde JSON de la API ROBLE
  factory User.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    int finalId;
    String? uuidValue;

    if (idValue is String) {
      // Si es String (UUID), calcular hash como int y guardar UUID
      uuidValue = idValue;
      finalId = idValue.hashCode.abs();
    } else if (idValue is int) {
      finalId = idValue;
    } else {
      finalId = 0;
    }

    return User(
      id: finalId,
      name: json['name'] ?? json['nombre'] ?? '',
      email: json['email'] ?? json['correo'] ?? '',
      imagepathh:
          json['avatarUrl'] ??
          json['image'] ??
          json['imagen'] ??
          json['imagepathh'],
      uuid: uuidValue,
    );
  }

  // Para convertir a Map (si quieres guardar o enviar datos)
  Map<String, dynamic> toMap() {
    return {
      'id': uuid ?? id, // Usar UUID si está disponible, sino el int
      'name': name,
      'email': email,
      'imagepathh': imagepathh,
    };
  }

  // Para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': uuid ?? id, // Usar UUID si está disponible, sino el int
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
    String? uuid,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imagepathh: imagepathh ?? this.imagepathh,
      uuid: uuid ?? this.uuid,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, uuid: $uuid, name: $name, email: $email, imagepathh: $imagepathh)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.imagepathh == imagepathh &&
        other.uuid == uuid;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        imagepathh.hashCode ^
        uuid.hashCode;
  }
}
