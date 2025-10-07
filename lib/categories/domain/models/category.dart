class Category {
  final String? id;
  final String name;
  final String? description;
  final String type;
  final String courseId;
  final int capacity;

  const Category({
    this.id,
    required this.name,
    this.description,
    required this.type,
    required this.courseId,
    required this.capacity,
  });

  // Normaliza tipo a los valores esperados por la DB (minúsculas)
  static String normalizeType(String t) {
    final s = t.trim().toLowerCase();
    if (s.startsWith('ale')) return 'aleatorio';
    if (s.startsWith('auto')) return 'auto-asignado';
    return s;
  }

  // Crear desde fila de la DB (columnas reales)
  factory Category.fromDb(Map<String, Object?> map) {
    return Category(
      id: map['id']?.toString(),
      name: (map['name'] as String?) ?? '',
      description: map['description'] as String?,
      type: normalizeType((map['type'] as String?) ?? ''),
      courseId: map['course_id']?.toString() ?? '',
      capacity: (map['capacity'] as int?) ?? 5, // Solo como fallback si no existe el campo
    );
  }

  // Convertir a Map para DB (columnas reales)
  Map<String, Object?> toDbMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'type': normalizeType(type),
      'course_id': courseId,
      'capacity': capacity,
      if (description != null) 'description': description,
    };
  }

  // Compatibilidad: crear desde Map genérico (por ejemplo, capa presentación)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toString(),
      name: (map['name'] ?? map['nombre'] ?? '') as String,
      description: (map['description'] ?? map['descripcion']) as String?,
      type: normalizeType((map['type'] ?? map['tipo'] ?? '') as String),
      courseId: (map['courseId'] ?? map['curso_id'] ?? '').toString(),
      capacity: (map['capacity'] ?? map['capacidad'] ?? 5) as int,
    );
  }

  // Compatibilidad: Map genérico (por ejemplo, para JSON o capa UI)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': normalizeType(type),
      'courseId': courseId,
      'capacity': capacity,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? courseId,
    int? capacity,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type != null ? normalizeType(type) : this.type,
      courseId: courseId ?? this.courseId,
      capacity: capacity ?? this.capacity,
    );
  }
}

class Member {
  final int id;
  final String name;
  final String? email;
  Member({required this.id, required this.name, this.email});
}
