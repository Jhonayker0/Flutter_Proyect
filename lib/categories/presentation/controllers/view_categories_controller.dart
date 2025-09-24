
import 'package:flutter_application/categories/domain/use_cases/delete_category_use_case.dart';
import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/models/category.dart';

// ViewModels para la UI
class CategoryVM {
  final String id;
  final String name;
  final String type;
  final String description;
  final String courseId;

  CategoryVM({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.courseId,
  });

  factory CategoryVM.fromDomain(Category c) => CategoryVM(
    id: c.id!,
    name: c.name,
    type: c.type,
    description: c.description ?? '',
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

  // factory GroupVM.fromDomain(GroupSummary g) =>
  //     GroupVM(id: g.id, name: g.name, capacity: g.capacity, members: g.members);
}

class CategoryGroupsController extends GetxController {
  final int courseId;
  final String role;
  CategoryGroupsController({
    required this.repo,
    required this.deleteCategoryUseCase,
    required this.courseId,
    required this.role,
  });
  final CategoryRepository repo;
  final DeleteCategory deleteCategoryUseCase;
  final categories = <CategoryVM>[].obs;
  final groupsByCat = <int, List<GroupVM>>{}.obs;
  final isLoading = false.obs;
  final loadingCat = <int>{}.obs;
  final error = RxnString();

  final userGroupByCategory = <int, int?>{}.obs;

  final AuthController authController = Get.find<AuthController>();
  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await repo.getAll(courseId.toString()); // List<Category>
      categories.assignAll(list.map(CategoryVM.fromDomain).toList());
      groupsByCat.clear(); // limpiar cache de grupos
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadGroupsFor(String categoriaId) async {
    // Funcionalidad de grupos temporalmente deshabilitada
    // TODO: Implementar cuando se requieran grupos
    /*
    if (groupsByCat.containsKey(categoriaId)) return;
    loadingCat.add(categoriaId);
    try {
      final groups = await repo.getGroupsByCategory(categoriaId);
      final mapped = groups.map(GroupVM.fromDomain).toList();
      groupsByCat[categoriaId] = mapped;

      // Detectar si el usuario ya está en algún grupo de esta categoría
      final userId = authController.currentUser.value?.id;
      int? foundGroupId;
      for (final g in mapped) {
        final members = await repo.getMembersByGroup(g.id, categoriaId);
        if (members.any((m) => m.id == userId)) {
          foundGroupId = g.id;
          break;
        }
      }
      userGroupByCategory[categoriaId] = foundGroupId;

      groupsByCat.refresh();
      userGroupByCategory.refresh();
    } catch (e) {
      error.value = e.toString();
    } finally {
      loadingCat.remove(categoriaId);
    }
    */
  }

  Future<void> refreshAll() async {
    groupsByCat.clear();
    await _loadCategories();
  }

  // Funcionalidad de grupos temporalmente deshabilitada
  // TODO: Implementar cuando se requieran grupos
  /*
  Future<List<MemberVM>> getMembersByGroup(int groupId, String categoriaId) async {
    final rows = await repo.getMembersByGroup(
      groupId,
      categoriaId,
    ); // devuelve List<Map> o List<Member>
    return rows
        .map((m) => MemberVM(id: m.id, name: m.name, email: m.email))
        .toList();
  }
  */

  Future<void> deleteCategory(String categoryId) async {
    try {
      await deleteCategoryUseCase(categoryId);

      Get.snackbar(
        'Categoría eliminada',
        'Se eliminó correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  // Funcionalidad de grupos temporalmente deshabilitada
  // TODO: Implementar cuando se requieran grupos
  /*
  Future<void> joinGroup(int groupId) async {
    final userId = authController.currentUser.value?.id;
    try {
      await repo.joinGroup(userId!, groupId);
      refreshAll();
      Get.snackbar("Éxito", "Te uniste al grupo");
      refreshAll();
    } catch (e) {
      Get.snackbar("Error", "No fue posible unirse: $e");
    }
  }

  // Métodos para profesores: gestión manual de estudiantes
  Future<void> assignStudentToGroup(
    int studentId,
    int groupId,
    String categoryId,
  ) async {
    try {
      await repo.assignStudentToGroup(studentId, groupId, categoryId);
      refreshAll();
      Get.snackbar("Éxito", "Estudiante asignado al grupo");
    } catch (e) {
      Get.snackbar("Error", "No se pudo asignar el estudiante: $e");
    }
  }

  Future<void> removeStudentFromGroup(int studentId, String categoryId) async {
    try {
      await repo.removeStudentFromGroup(studentId, categoryId);
      refreshAll();
      Get.snackbar("Éxito", "Estudiante removido del grupo");
    } catch (e) {
      Get.snackbar("Error", "No se pudo remover el estudiante: $e");
    }
  }

  Future<List<MemberVM>> getUnassignedStudents(String categoryId) async {
    try {
      final students = await repo.getUnassignedStudents(courseId, categoryId);
      return students
          .map((s) => MemberVM(id: s.id, name: s.name, email: s.email))
          .toList();
    } catch (e) {
      Get.snackbar("Error", "No se pudieron cargar los estudiantes: $e");
      return [];
    }
  }
  */

  // Métodos temporales vacíos para evitar errores en la UI
  // TODO: Implementar cuando se requiera funcionalidad de grupos
  
  Future<void> joinGroup(int groupId) async {
    Get.snackbar("Info", "Funcionalidad de grupos próximamente disponible");
  }

  Future<List<MemberVM>> getMembersByGroup(int groupId, String categoryId) async {
    return [];
  }

  Future<List<MemberVM>> getUnassignedStudents(String categoryId) async {
    return [];
  }

  Future<void> assignStudentToGroup(int studentId, int groupId, String categoryId) async {
    Get.snackbar("Info", "Funcionalidad de grupos próximamente disponible");
  }

  Future<void> removeStudentFromGroup(int studentId, String categoryId) async {
    Get.snackbar("Info", "Funcionalidad de grupos próximamente disponible");
  }
}
