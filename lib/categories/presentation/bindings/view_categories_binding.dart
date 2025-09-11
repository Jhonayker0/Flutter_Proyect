
import 'package:flutter_application/categories/data/repositories/category_repository_impl.dart';
import 'package:flutter_application/categories/data/services/category_service.dart';
import 'package:flutter_application/courses/domain/models/course.dart';
import 'package:flutter_application/categories/domain/repositories/category_repository.dart';
import 'package:flutter_application/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:flutter_application/categories/presentation/controllers/view_categories_controller.dart';
import 'package:get/get.dart';

class CategoryGroupsBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>?;
    
    // Intentar obtener courseId y role de diferentes formas
    int courseId;
    String role = 'profesor'; // Cambiar por defecto a profesor para mostrar los controles
    
    if (args != null) {
      if (args.containsKey('course')) {
        final course = args['course'] as Course;
        courseId = course.id!;
        role = args['role'] as String? ?? 'estudiante';
      } else if (args.containsKey('courseId')) {
        courseId = (args['courseId'] as num).toInt();
        role = args['role'] as String? ?? 'estudiante';
      } else {
        courseId = 1; // valor por defecto para desarrollo
      }
    } else {
      courseId = 1; // valor por defecto para desarrollo
    }
    
    Get.lazyPut<CategoryService>(() => CategoryService());
    Get.lazyPut<CategoryRepository>(() => CategoryRepositoryImpl(Get.find())); 

    final repo = CategoryRepositoryImpl(CategoryService());
    final useCase = DeleteCategory(repo);
    Get.lazyPut<CategoryGroupsController>(() => CategoryGroupsController(
      repo: Get.find(), 
      deleteCategoryUseCase: useCase, 
      courseId: courseId, 
      role: role
    )); 
  }
}







