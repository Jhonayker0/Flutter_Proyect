class Activity {
  final String name;
  final String? description;
  final DateTime? deadline;
  final String category;
  final String? attachmentPath;

  const Activity({
    required this.name,
    required this.category,
    this.description,
    this.deadline,
    this.attachmentPath,
  });
}
