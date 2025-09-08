import 'package:flutter_application/data/repositories/category_repository_impl.dart';
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
  CategoryGroupsController({required this.repo});
  final CategoryRepository repo;


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
      final list = await repo.getAll();                 // List<Category>
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
}
