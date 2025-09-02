import 'package:flutter_application/domain/models/category.dart';

abstract class CategoryRepository {
  Future<void> create(Category category);
}
