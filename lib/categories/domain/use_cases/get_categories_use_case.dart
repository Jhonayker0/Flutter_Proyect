import '../models/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repo;
  GetCategories(this.repo);

  Future<List<Category>> call(int courseId) => repo.getAll(courseId);
}
