import 'package:get/get.dart';
import '../../data/services/category_service.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/use_cases/update_category_use_case.dart';
import '../controllers/edit_category_controller.dart';

class EditCategoryBinding extends Bindings {
  @override
  void dependencies() {
    final service = CategoryService();
    final repo = CategoryRepositoryImpl(service);
    final updateCategoryUseCase = UpdateCategory(repo);

    Get.put(
      EditCategoryController(
        updateCategoryUseCase: updateCategoryUseCase,
        categoryRepository: repo,
      ),
    );
  }
}
