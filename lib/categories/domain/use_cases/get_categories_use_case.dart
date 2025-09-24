import '../models/category.dart';
import '../repositories/category_repository.dart';

class GetCategories {
  final CategoryRepository repo;
  GetCategories(this.repo);

  Future<List<Category>> call(String courseId) => repo.getAll(courseId);
}
