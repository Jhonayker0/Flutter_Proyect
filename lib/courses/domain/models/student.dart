class Student {
  final int? id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime enrolledAt;
  final int courseId;
  final double? averageGrade;
  final int completedActivities;
  final int totalActivities;

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.courseId,
    this.profileImage,
    DateTime? enrolledAt,
    this.averageGrade,
    this.completedActivities = 0,
    this.totalActivities = 0,
  }) : enrolledAt = enrolledAt ?? DateTime.now();

  Student copyWith({
    int? id,
    String? name,
    String? email,
    String? profileImage,
    DateTime? enrolledAt,
    int? courseId,
    double? averageGrade,
    int? completedActivities,
    int? totalActivities,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      courseId: courseId ?? this.courseId,
      averageGrade: averageGrade ?? this.averageGrade,
      completedActivities: completedActivities ?? this.completedActivities,
      totalActivities: totalActivities ?? this.totalActivities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'enrolledAt': enrolledAt.toIso8601String(),
      'courseId': courseId,
      'averageGrade': averageGrade,
      'completedActivities': completedActivities,
      'totalActivities': totalActivities,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      enrolledAt: DateTime.parse(json['enrolledAt']),
      courseId: json['courseId'],
      averageGrade: json['averageGrade']?.toDouble(),
      completedActivities: json['completedActivities'] ?? 0,
      totalActivities: json['totalActivities'] ?? 0,
    );
  }

  double get progressPercentage {
    if (totalActivities == 0) return 0.0;
    return (completedActivities / totalActivities) * 100;
  }
}







