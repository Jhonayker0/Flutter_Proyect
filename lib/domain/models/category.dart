class Category {
  final int? id;
  final String name;
  final String description;
  final String type;     // "Auto-asignado" | "Aleatorio"
  final int capacity;

  const Category({
    this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.capacity,
  });

  // Para crear desde un Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      capacity: map['capacity'] ?? 0,
    );
  }

  // Para convertir a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'capacity': capacity,
    };
  }

  // Para crear una copia con cambios
  Category copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    int? capacity,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
    );
  }
}
