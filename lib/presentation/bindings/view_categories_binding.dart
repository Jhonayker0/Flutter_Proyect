
import 'package:flutter_application/data/repositories/category_repository_impl.dart';
import 'package:flutter_application/data/services/category_service.dart';
import 'package:flutter_application/domain/models/course.dart';
import 'package:flutter_application/domain/repositories/category_repository.dart';
import 'package:flutter_application/domain/use_cases/delete_category_use_case.dart';
import 'package:flutter_application/presentation/controllers/view_categories_controller.dart';
import 'package:get/get.dart';

class CategoryGroupsBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>;
    final course = args['course'] as Course;
    final role = args['role'] as String?;
    Get.lazyPut<CategoryService>(() => CategoryService());
    Get.lazyPut<CategoryRepository>(() => CategoryRepositoryImpl(Get.find())); 

    final repo = CategoryRepositoryImpl(CategoryService());
    final useCase = DeleteCategory(repo);
    Get.lazyPut<CategoryGroupsController>(() => CategoryGroupsController(repo: Get.find(), deleteCategoryUseCase: useCase, courseId: course.id!, role: role!)); 
  }
}
