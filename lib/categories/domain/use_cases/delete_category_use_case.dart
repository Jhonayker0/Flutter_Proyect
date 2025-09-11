import '../repositories/category_repository.dart';

class DeleteCategory {
  final CategoryRepository repo;
  DeleteCategory(this.repo);

  Future<void> call(int id) => repo.delete(id);
}







