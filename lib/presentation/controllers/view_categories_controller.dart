import 'package:flutter_application/data/repositories/category_repository_impl.dart';
import 'package:flutter_application/domain/use_cases/delete_category_use_case.dart';
import 'package:get/get.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/models/category.dart';        


// ViewModels para la UI
class CategoryVM {
  final int id;
  final String name;
  final String type;    
  final int? capacity;
  final int courseId;

  CategoryVM({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
    required this.courseId,
  });


  factory CategoryVM.fromDomain(Category c) => CategoryVM(
        id: c.id!,              
        name: c.name,
        type: c.type,
        capacity: c.capacity,
        courseId: c.courseId,
      );
}
class MemberVM {
  final int id;
  final String name;
  final String? email;
  MemberVM({required this.id, required this.name, this.email});
}
class GroupVM {
  final int id;
  final String name;
  final int? capacity;
  final int members;

  GroupVM({
    required this.id,
    required this.name,
    this.capacity,
    required this.members,
  });

  factory GroupVM.fromDomain(GroupSummary g) => GroupVM(
        id: g.id,
        name: g.name,
        capacity: g.capacity,
        members: g.members,
      );
}

class CategoryGroupsController extends GetxController {
  final int courseId;
  final String role;
  CategoryGroupsController({required this.repo, required this.deleteCategoryUseCase, required this.courseId, required this.role});
  final CategoryRepository repo;
  final DeleteCategory deleteCategoryUseCase;
  final categories = <CategoryVM>[].obs;
  final groupsByCat = <int, List<GroupVM>>{}.obs;
  final isLoading = false.obs;
  final loadingCat = <int>{}.obs;                 
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await repo.getAll(courseId);                 // List<Category>
      categories.assignAll(list.map(CategoryVM.fromDomain).toList());
      groupsByCat.clear();                              // limpiar cache de grupos
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupsFor(int categoriaId) async {
    if (groupsByCat.containsKey(categoriaId)) return;   // cache simple
    loadingCat.add(categoriaId);
    try {
      final groups = await repo.getGroupsByCategory(categoriaId); // List<GroupSummary>
      groupsByCat[categoriaId] = groups.map(GroupVM.fromDomain).toList();
      groupsByCat.refresh();                             // notificar cambio en RxMap
    } catch (e) {
      error.value = e.toString();
    } finally {
      loadingCat.remove(categoriaId);
    }
  }

  Future<void> refreshAll() async {
    groupsByCat.clear();
    await _loadCategories();
  }
  
  Future<List<MemberVM>> getMembersByGroup(int groupId, int categoriaId) async {

    final rows = await repo.getMembersByGroup(groupId, categoriaId); // devuelve List<Map> o List<Member>
    return rows.map((m) => MemberVM(
      id: m.id,
      name: m.name,
      email: m.email,
    )).toList();
  }

  Future<void> deleteCategory(int categoryId) async {
  try {
 
    await deleteCategoryUseCase(categoryId);

    Get.snackbar('Categoría eliminada', 'Se eliminó correctamente', snackPosition: SnackPosition.BOTTOM);
  } catch (e) {
    
    Get.snackbar('Error', 'No se pudo eliminar: $e', snackPosition: SnackPosition.BOTTOM);
    rethrow; 
  }
}
}