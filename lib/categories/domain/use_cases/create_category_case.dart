import '../models/category.dart';
import '../repositories/category_repository.dart';

class CreateCategory {
  final CategoryRepository repo;
  CreateCategory(this.repo);

  Future<void> call(Category category) => repo.create(category);
}
