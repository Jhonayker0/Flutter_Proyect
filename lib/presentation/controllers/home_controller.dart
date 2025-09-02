import 'package:get/get.dart';
import '../../routes.dart';

class Course {
  final String title;
  final String role; // 'Professor' | 'Student'
  Course({required this.title, required this.role});
}

class HomeController extends GetxController {
  // Lista maestra (no reactiva) y lista filtrada (reactiva)
  final List<Course> _allCourses = [];
  final RxList<Course> courses = <Course>[].obs;

  // Filtro de rol activo y búsqueda
  final RxnString activeRoleFilter = RxnString(); // 'Professor' o 'Student'
  final RxString searchQuery = ''.obs;

  static const String roleProfessor = 'Professor';
  static const String roleStudent = 'Student';

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  // Simulación de carga (reemplazar por caso de uso/Repo si aplica)
  Future<void> loadCourses() async {
    // TODO: reemplazar por use case de dominio si ya existe
    _allCourses.clear();
    _allCourses.addAll( [
      Course(title: "Alicias Course", role: roleStudent),
      Course(title: "UI/UX", role: roleStudent),
      Course(title: "DATA´S STRUCTURE II", role: roleStudent),
      Course(title: "Mobile´s course", role: roleProfessor),
      Course(title: "Mobile’s course", role: roleProfessor),
    ]);
    applyFilters();
  }

  void setSearchQuery(String q) {
    searchQuery.value = q;
    applyFilters();
  }

  void setRoleFilter(String role) {
    activeRoleFilter.value = role;
    applyFilters();
  }

  void clearRoleFilter() {
    activeRoleFilter.value = null;
    applyFilters();
  }

  void applyFilters() {
    final role = activeRoleFilter.value;
    final query = searchQuery.value.trim().toLowerCase();

    var list = _allCourses;

    if (role != null) {
      list = list.where((c) => c.role == role).toList();
    }
    if (query.isNotEmpty) {
      list = list.where((c) => c.title.toLowerCase().contains(query)).toList();
    }

    courses.assignAll(list);
  }

  String get activeRoleFilterLabel {
    switch (activeRoleFilter.value) {
      case roleProfessor:
        return 'Profesor';
      case roleStudent:
        return 'Estudiante';
      default:
        return '';
    }
  } 

  void goToProfile() {
    Get.toNamed(Routes.settings);
  }

  void logout() {
    Get.offAllNamed(Routes.login);
  }

  void onOptionSelected(String value) {
    if (value == "perfil") {
      goToProfile();
    } else if (value == "logout") {
      logout();
    } else {
      Get.snackbar("Opción", "$value seleccionado");
    }
  }
}
