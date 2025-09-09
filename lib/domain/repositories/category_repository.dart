import 'package:flutter_application/data/repositories/category_repository_impl.dart';
import 'package:flutter_application/domain/models/category.dart';

abstract class CategoryRepository {
  Future<int> create(Category category);
  Future<List<Category>> getAll(int courseId);
  Future<Category?> getById(int id);
  Future<void> update(Category category);
  Future<void> delete(int id);
  Future<List<GroupSummary>> getGroupsByCategory(int categoriaId);
  Future<List<Member>> getMembersByGroup(int groupId, int categoryId);
}
