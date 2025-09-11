class Activity {
  final int? id;
  final String title;
  final String description;
  final String type; // 'Tarea', 'Examen', 'Proyecto', etc.
  final DateTime dueDate;
  final DateTime createdAt;
  final bool isCompleted;
  final double? grade;
  final int courseId;

  Activity({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.dueDate,
    required this.courseId,
    DateTime? createdAt,
    this.isCompleted = false,
    this.grade,
  }) : createdAt = createdAt ?? DateTime.now();

  Activity copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isCompleted,
    double? grade,
    int? courseId,
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
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      isCompleted: json['isCompleted'] ?? false,
      grade: json['grade']?.toDouble(),
      courseId: json['courseId'],
    );
  }
}







