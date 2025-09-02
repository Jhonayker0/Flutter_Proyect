
import 'package:flutter_application/domain/models/category.dart';
import 'package:flutter_application/domain/repositories/category_repository.dart';
import '../services/category_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryService service;
  CategoryRepositoryImpl(this.service);

  @override
  Future<void> create(Category category) async {
    final dto = {
      'name': category.name,
      'description': category.description,
      'type': category.type,
      'capacity': category.capacity,
    };
    await service.postCategory(dto);
  }
}
