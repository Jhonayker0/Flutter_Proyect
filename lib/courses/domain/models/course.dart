class Course {
  final String? id; // Cambio de int a String para ROBLE _id
  final String title;
  final String description;
  final String? code; // Agregar code field
  final String professorId; // Cambio de int a String para UUID
  final String role; // "Student" o "Professor"
  final DateTime createdAt;

  Course({
    this.id,
    required this.title,
    required this.description,
    this.code,
    required this.professorId,
    required this.role,
    required this.createdAt,
  });

  /// Crear un Course desde ROBLE response
  factory Course.fromRoble(Map<String, dynamic> map, {String? currentUserId}) {
    final professorId = map['professor_id'] as String? ?? '';
    final role = (currentUserId != null && currentUserId == professorId)
        ? 'Profesor'
        : 'Estudiante';

    return Course(
      id: map['_id'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      code: map['code'] as String?,
      professorId: professorId,
      role: role,
      createdAt: DateTime.now(), // ROBLE no retorna fecha aún
    );
  }

  /// Crear un Course desde SQLite (para compatibilidad)
  factory Course.fromMap(Map<String, dynamic> map, {int? currentUserId}) {
    final profesorId = map['profesor_id'] as int;
    final role = (currentUserId != null && currentUserId == profesorId)
        ? 'Profesor'
        : 'Estudiante';

    final createdAtStr = map['created_at'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.parse(createdAtStr)
        : DateTime.now();

    return Course(
      id: map['id']?.toString(), // Convertir int a String
      title: map['nombre_asignatura'] as String? ?? '',
      description: map['descripcion'] as String? ?? '',
      code: map['codigo'] as String?,
      professorId: profesorId.toString(), // Convertir int a String
      role: role,
      createdAt: createdAt,
    );
  }

  /// Convertir a Map para ROBLE insert/update
  Map<String, dynamic> toRoble() {
    return {
      if (id != null) '_id': id,
      'title': title,
      'description': description,
      if (code != null) 'code': code,
      'professor_id': professorId,
    };
  }

  /// Convertir a Map para SQLite (compatibilidad)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': int.tryParse(id!) ?? 0,
      'nombre_asignatura': title,
      'descripcion': description,
      'codigo': code ?? '$title 1234567',
      'profesor_id': int.tryParse(professorId) ?? 0,
    };
  }
}







