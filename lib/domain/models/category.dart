class Category {
  final String name;
  final String description;
  final String type;     // "Auto-asignado" | "Aleatorio"
  final int capacity;

  const Category({
    required this.name,
    required this.description,
    required this.type,
    required this.capacity,
  });
}
