import '../models/category.dart';
import '../repositories/category_repository.dart';

class UpdateCategory {
  final CategoryRepository repo;
  UpdateCategory(this.repo);

  Future<void> call(Category category) => repo.update(category);
}







