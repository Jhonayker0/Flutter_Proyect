
import 'package:flutter_application/data/repositories/category_repository_impl.dart';
import 'package:flutter_application/data/services/category_service.dart';
import 'package:flutter_application/domain/repositories/category_repository.dart';
import 'package:flutter_application/presentation/controllers/view_categories_controller.dart';
import 'package:get/get.dart';

class CategoryGroupsBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<CategoryService>(() => CategoryService());
    Get.lazyPut<CategoryRepository>(() => CategoryRepositoryImpl(Get.find())); 

    Get.lazyPut<CategoryGroupsController>(() => CategoryGroupsController(repo: Get.find())); 
  }
}
