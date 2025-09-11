import 'package:get/get.dart';
import '../../data/services/category_service.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/use_cases/get_categories_use_case.dart';
import '../../domain/use_cases/delete_category_use_case.dart';
import '../controllers/categories_controller.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    final service = CategoryService();
    final repo = CategoryRepositoryImpl(service);
    final getCategoriesUseCase = GetCategories(repo);
    final deleteCategoryUseCase = DeleteCategory(repo);
    
    Get.put(CategoriesController(
      getCategoriesUseCase: getCategoriesUseCase,
      deleteCategoryUseCase: deleteCategoryUseCase,
    ));
  }
}







