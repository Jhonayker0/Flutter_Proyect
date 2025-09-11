import 'package:get/get.dart';
import '../../data/services/category_service.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/use_cases/create_category_case.dart';
import '../controllers/create_category_controller.dart';

class CreateCategoryBinding extends Bindings {
  @override
  void dependencies() {
    final service = CategoryService();
    final repo = CategoryRepositoryImpl(service);
    final useCase = CreateCategory(repo);
    Get.put(CreateCategoryController(createCategoryUseCase: useCase));
  }
}







