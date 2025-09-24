import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repo;
  DeleteCategory(this.repo);

  Future<void> call(String id) => repo.delete(id);
}
