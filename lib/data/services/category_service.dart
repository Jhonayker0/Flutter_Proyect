class CategoryService {
  static final List<Map<String, dynamic>> _categories = [
    {
      'id': 1,
      'name': 'Programación',
      'description': 'Categoría para cursos de desarrollo de software',
      'type': 'Auto-asignado',
      'capacity': 30,
    },
    {
      'id': 2,
      'name': 'Diseño',
      'description': 'Categoría para cursos de diseño gráfico y UX/UI',
      'type': 'Aleatorio',
      'capacity': 25,
    },
  ];
  static int _nextId = 3;

  Future<void> postCategory(Map<String, dynamic> json) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 500));
    
    final category = Map<String, dynamic>.from(json);
    category['id'] = _nextId++;
    _categories.add(category);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<Map<String, dynamic>>.from(_categories);
  }

  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _categories.firstWhere((cat) => cat['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateCategory(int id, Map<String, dynamic> json) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _categories.indexWhere((cat) => cat['id'] == id);
    if (index != -1) {
      final updatedCategory = Map<String, dynamic>.from(json);
      updatedCategory['id'] = id;
      _categories[index] = updatedCategory;
    }
  }

  Future<void> deleteCategory(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _categories.removeWhere((cat) => cat['id'] == id);
  }
}
