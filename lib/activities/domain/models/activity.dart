class Activity {
  final String? id; // ROBLE usa String IDs
  final String title;
  final String description;
  final String type; // 'Tarea', 'Examen', 'Proyecto', etc.
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isCompleted;
  final double? grade;
  final String courseId; // ROBLE usa String IDs
  final String? categoryId; // Nuevo campo para categoría

  Activity({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.dueDate,
    required this.courseId,
    this.categoryId,
    DateTime? createdAt,
    this.isCompleted = false,
    this.grade,
  }) : createdAt = createdAt ?? DateTime.now();

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
    double? grade,
    String? courseId,
    String? categoryId,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      grade: grade ?? this.grade,
      courseId: courseId ?? this.courseId,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'grade': grade,
      'courseId': courseId,
      'categoryId': categoryId,
    };
  }

  /// Convertir a formato ROBLE
  Map<String, dynamic> toRoble() {
    return {
      'title': title,
      'description': description,
      // Removido 'type' porque no existe en la tabla ROBLE
      'due_date': dueDate.toIso8601String(),
      'course_id': courseId,
      'category_id': categoryId,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Tarea',
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      grade: json['grade']?.toDouble(),
      courseId: json['courseId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
    );
  }

  /// Crear desde formato ROBLE
  factory Activity.fromRoble(Map<String, dynamic> json) {
    return Activity(
      id: json['_id']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Tarea',
      dueDate: json['due_date'] != null 
        ? DateTime.parse(json['due_date'])
        : DateTime.now(),
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
      isCompleted: json['is_completed'] ?? false,
      grade: json['grade']?.toDouble(),
      courseId: json['course_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString(),
    );
  }
}
