import 'package:flutter_application/auth/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_application/routes.dart';

class Course {
  final int? id;
  final String title;
  final String role; // 'Profesor' | 'Estudiante'
  final DateTime createdAt;
  final int students; // Número de estudiantes
  final String? description;
  
  Course({
    this.id,
    required this.title, 
    required this.role,
    DateTime? createdAt,
    this.students = 0,
    this.description,
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

  static const String roleProfessor = 'Profesor';
  static const String roleStudent = 'Estudiante';

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
        id: 1,
        title: "Alicia's Course", 
        role: roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        students: 25,
        description: "Curso introductorio de programación",
      ),
      Course(
        id: 2,
        title: "UI/UX Design", 
        role: roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        students: 18,
        description: "Fundamentos de diseño de interfaces",
      ),
      Course(
        id: 3,
        title: "DATA STRUCTURE II", 
        role: roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        students: 30,
        description: "Estructuras de datos avanzadas",
      ),
      Course(
        id: 4,
        title: "Desarrollo Móvil", 
        role: roleProfessor,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        students: 22,
        description: "Desarrollo de aplicaciones móviles nativas",
      ),
      Course(
        id: 5,
        title: "Flutter Avanzado", 
        role: roleProfessor,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        students: 15,
        description: "Desarrollo avanzado con Flutter",
      ),
      Course(
        id: 6,
        title: "JavaScript Básico", 
        role: roleStudent,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        students: 35,
        description: "Fundamentos de JavaScript",
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
        return 'Nombre A-Z';
      case SortOption.nameDesc:
        return 'Nombre Z-A';
      case SortOption.dateAsc:
        return 'Más antiguos';
      case SortOption.dateDesc:
        return 'Más recientes';
      case SortOption.studentsAsc:
        return 'Menos estudiantes';
      case SortOption.studentsDesc:
        return 'Más estudiantes';
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
        return 'Profesor';
      case roleStudent:
        return 'Estudiante';
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







