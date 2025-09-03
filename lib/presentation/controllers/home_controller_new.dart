import 'package:flutter_application/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../../routes.dart';

class Course {
  final String title;
  final String role; // 'Professor' | 'Student'
  final DateTime createdAt;
  final int students; // Número de estudiantes
  
  Course({
    required this.title, 
    required this.role,
    DateTime? createdAt,
    this.students = 0,
  }) : createdAt = createdAt ?? DateTime.now();
}

enum SortOption {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
  studentsAsc,
  studentsDesc,
}

class HomeController extends GetxController {
  final List<Course> _allCourses = [];
  final RxList<Course> courses = <Course>[].obs;

  // Estados de filtros y búsqueda
  final RxnString activeRoleFilter = RxnString();
  final RxString searchQuery = ''.obs;
  final Rx<SortOption> currentSort = SortOption.nameAsc.obs;
  final RxInt activeFilters = 0.obs;

  static const String roleProfessor = 'Professor';
  static const String roleStudent = 'Student';

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  // Simulación de carga con más datos
  Future<void> loadCourses() async {
    _allCourses.clear();
    _allCourses.addAll([
      Course(
        title: "Alicia's Course", 
        role: roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        students: 25,
      ),
      Course(
        title: "UI/UX Design", 
        role: roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        students: 18,
      ),
      Course(
        title: "DATA STRUCTURE II", 
        role: roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        students: 30,
      ),
      Course(
        title: "Mobile Development", 
        role: roleProfessor,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        students: 22,
      ),
      Course(
        title: "Flutter Advanced", 
        role: roleProfessor,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        students: 15,
      ),
      Course(
        title: "JavaScript Basics", 
        role: roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        students: 35,
      ),
    ]);
    applyFilters();
  }

  // FUNCIONALIDAD DE BÚSQUEDA
  void setSearchQuery(String q) {
    searchQuery.value = q;
    applyFilters();
  }

  // FUNCIONALIDAD DE FILTROS
  void setRoleFilter(String? role) {
    activeRoleFilter.value = role;
    updateFilterCount();
    applyFilters();
  }

  void clearRoleFilter() {
    activeRoleFilter.value = null;
    updateFilterCount();
    applyFilters();
  }

  void updateFilterCount() {
    int count = 0;
    if (activeRoleFilter.value != null) count++;
    activeFilters.value = count;
  }

  // FUNCIONALIDAD DE ORDENAMIENTO
  void setSortOption(SortOption option) {
    currentSort.value = option;
    applyFilters();
  }

  String get sortLabel {
    switch (currentSort.value) {
      case SortOption.nameAsc:
        return 'Name A-Z';
      case SortOption.nameDesc:
        return 'Name Z-A';
      case SortOption.dateAsc:
        return 'Oldest First';
      case SortOption.dateDesc:
        return 'Newest First';
      case SortOption.studentsAsc:
        return 'Less Students';
      case SortOption.studentsDesc:
        return 'More Students';
    }
  }

  List<Course> _sortCourses(List<Course> courses) {
    switch (currentSort.value) {
      case SortOption.nameAsc:
        courses.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameDesc:
        courses.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.dateAsc:
        courses.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.dateDesc:
        courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.studentsAsc:
        courses.sort((a, b) => a.students.compareTo(b.students));
        break;
      case SortOption.studentsDesc:
        courses.sort((a, b) => b.students.compareTo(a.students));
        break;
    }
    return courses;
  }

  // APLICAR TODOS LOS FILTROS
  void applyFilters() {
    final role = activeRoleFilter.value;
    final query = searchQuery.value.trim().toLowerCase();

    var list = List<Course>.from(_allCourses);

    // Aplicar filtro de rol
    if (role != null) {
      list = list.where((c) => c.role == role).toList();
    }

    // Aplicar búsqueda
    if (query.isNotEmpty) {
      list = list.where((c) => c.title.toLowerCase().contains(query)).toList();
    }

    // Aplicar ordenamiento
    list = _sortCourses(list);

    courses.assignAll(list);
  }

  String get activeRoleFilterLabel {
    switch (activeRoleFilter.value) {
      case roleProfessor:
        return 'Professor';
      case roleStudent:
        return 'Student';
      default:
        return '';
    }
  } 

  RxString get currentUserName {
    final authController = Get.find<AuthController>();
    return (authController.currentUser.value?.name ?? 'Usuario').obs;
  }

  void goToProfile() {
    Get.toNamed(Routes.settings);
  }

  void logout() {
    final authController = Get.find<AuthController>();
    authController.logout(); 
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
