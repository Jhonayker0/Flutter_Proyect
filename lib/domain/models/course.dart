class Course {
  final String name;
  final String description;
  final DateTime? deadline;
  final String? imagePath; // opcional, botón "Añadir imagen"

  const Course({
    required this.name,
    required this.description,
    this.deadline,
    this.imagePath,
  });
}
