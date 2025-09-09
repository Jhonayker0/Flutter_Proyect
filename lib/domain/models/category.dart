class Category {
  final int? id;
  final String name;          
  final String? description; 
  final String type;         
  final int? capacity;        
  final int courseId;        

  const Category({
    this.id,
    required this.name,
    this.description,
    required this.type,
    this.capacity,
    required this.courseId,
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
      id: map['id'] as int?,
      name: (map['nombre'] as String?) ?? '',
      // si agregas columna 'descripcion' en DB, mapéala aquí
      description: map['descripcion'] as String?,
      type: normalizeType((map['tipo'] as String?) ?? ''),
      capacity: (map['capacidad'] as int?),
      courseId: (map['curso_id'] as num).toInt(),
    );
  }

  // Convertir a Map para DB (columnas reales)
  Map<String, Object?> toDbMap() {
    return {
      if (id != null) 'id': id,
      'nombre': name,
      'tipo': normalizeType(type),
      'capacidad': capacity,
      'curso_id': courseId,
      if (description != null) 'descripcion': description, // solo si existe en DB
    };
  }

  // Compatibilidad: crear desde Map genérico (por ejemplo, capa presentación)
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: (map['name'] ?? map['nombre'] ?? '') as String,
      description: (map['description'] ?? map['descripcion']) as String?,
      type: normalizeType((map['type'] ?? map['tipo'] ?? '') as String),
      capacity: (map['capacity'] ?? map['capacidad']) as int?,
      courseId: (map['courseId'] ?? map['curso_id']) is num
          ? (map['courseId'] ?? map['curso_id'] as num).toInt()
          : int.parse((map['courseId'] ?? map['curso_id'] ?? '0').toString()),
    );
  }

  // Compatibilidad: Map genérico (por ejemplo, para JSON o capa UI)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': normalizeType(type),
      'capacity': capacity,
      'courseId': courseId,
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    int? capacity,
    int? courseId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type != null ? normalizeType(type) : this.type,
      capacity: capacity ?? this.capacity,
      courseId: courseId ?? this.courseId,
    );
  }
}
class Member {
  final int id;
  final String name;
  final String? email;
  Member({required this.id, required this.name, this.email});
}