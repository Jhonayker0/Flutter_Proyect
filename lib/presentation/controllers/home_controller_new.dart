import 'package:flutter_application/domain/models/course.dart';
import 'package:flutter_application/domain/repositories/course_repository.dart';
import 'package:flutter_application/presentation/controllers/auth_controller.dart';
import 'package:get/get.dart';
import '../../routes.dart';


enum SortOption {
  nameAsc,
  nameDesc,
  dateAsc,
  dateDesc,
  studentsAsc,
  studentsDesc,
}

class HomeController extends GetxController {
  final CourseRepository courseRepository;
  HomeController({required this.courseRepository});

  final courses = <Course>[].obs;
  final _allCourses = <Course>[];

  final activeRoleFilter = RxnString();
  final searchQuery = ''.obs;
  final currentSort = SortOption.nameAsc.obs;
  final activeFilters = 0.obs;

  static const String roleProfessor = 'Professor';
  static const String roleStudent = 'Student';

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  Future<void> loadCourses() async {
    final authController = Get.find<AuthController>();
    final userId = authController.currentUser.value?.id;

    if (userId == null) return;

    _allCourses.clear();

    // Traer cursos del estudiante
    final studentCourses = await courseRepository.getCoursesByStudent(userId);
    // Traer cursos del profesor
    final professorCourses = await courseRepository.getCoursesByProfesor(userId);

    _allCourses.addAll([...studentCourses, ...professorCourses]);
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
  void addCourse(Course course) {
    _allCourses.add(course);
    applyFilters(); // esto actualiza la lista observable `courses`
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
