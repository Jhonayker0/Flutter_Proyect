class Course {
  final int? id;
  final String title;
  final String description;
  final int profesorId;
  final String role;      // "Student" o "Professor"
  final int students;     // número de estudiantes
  final DateTime createdAt;

  Course({
    this.id,
    required this.title,
    required this.description,
    required this.profesorId,
    required this.role,
    required this.students,
    required this.createdAt,
  });

  /// Crear un Course desde un Map de la DB
  factory Course.fromMap(Map<String, dynamic> map, {int? currentUserId}) {
    final profesorId = map['profesor_id'] as int;
    final role = (currentUserId != null && currentUserId == profesorId)
        ? 'Profesor'
        : 'Estudiante';

    final students = map['students'] != null
        ? map['students'] as int
        : 0; // si no viene, asumir 0

    final createdAtStr = map['created_at'] as String?;
    final createdAt = createdAtStr != null
        ? DateTime.parse(createdAtStr)
        : DateTime.now();

    return Course(
      id: map['id'] as int?,
      title: map['nombre_asignatura'] as String? ?? '',
      description: map['descripcion'] as String? ?? '',
      profesorId: profesorId,
      role: role,
      students: students,
      createdAt: createdAt,
    );
  }

  /// Convertir a Map para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre_asignatura': title,
      'descripcion': description,
      'profesor_id': profesorId,
      'codigo': '1234567'
    };
  }
}
