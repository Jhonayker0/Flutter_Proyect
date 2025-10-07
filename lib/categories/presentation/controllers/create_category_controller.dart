// presentation/controllers/create_category_controller.dart
import 'package:flutter_application/categories/domain/models/category.dart';
import 'package:flutter_application/categories/domain/use_cases/create_category_case.dart';
import 'package:flutter_application/courses/presentation/controllers/course_detail_controller.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/core/services/roble_user_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CreateCategoryController extends GetxController {
  final CreateCategory createCategoryUseCase;
  CreateCategoryController({required this.createCategoryUseCase});
  late final String courseId;
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final capacityCtrl = TextEditingController(text: '5');

  final type = RxnString(); // "aleatorio" | "eleccion"
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    if (args != null && args['courseId'] != null) {
      courseId = (args['courseId'] as String);
    } else {
      // Valor por defecto o manejo de error
      Get.snackbar(
        'Error',
        'ID del curso no encontrado',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
      return;
    }
  }

  String? validateRequired(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? validateType(String? v) => v == null ? 'Selecciona un tipo' : null;
  
  String? validateCapacity(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa la capacidad';
    final capacity = int.tryParse(v.trim());
    if (capacity == null || capacity <= 0) return 'Debe ser un número mayor a 0';
    if (capacity > 50) return 'Capacidad máxima es 50';
    return null;
  }

  void setType(String? v) => type.value = v;

  Future<void> submit(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    error.value = null;
    try {
      final category = Category(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        type: type.value!, // validado
        courseId: courseId, // Ya es String
        capacity: int.parse(capacityCtrl.text.trim()),
      );
      
      // Crear la categoría primero
      await createCategoryUseCase.call(category);
      
      // Ahora crear los grupos automáticamente con asignación según el tipo
      await _createGroupsAutomatically(category);

      // Refrescar las categorías en el curso
      if (Get.isRegistered<CourseDetailController>()) {
        Get.find<CourseDetailController>().loadRobleCategories();
      }
      Get.back(result: true);
      Get.snackbar('Exito', 'Categoría creada');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear la categoría $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Crea grupos automáticamente después de crear una categoría
  Future<void> _createGroupsAutomatically(Category category) async {
    try {
      // Importar los servicios necesarios
      final httpService = RobleHttpService();
      final databaseService = RobleDatabaseService(httpService);
      final userService = RobleUserService(databaseService);
      
      // Obtener estudiantes del curso
      final students = await userService.getUsersByCourse(courseId);
      final studentsList = students.where((u) => u['role'] == 'student').toList();
      
      print('📚 Creando grupos automáticamente:');
      print('   - Estudiantes en el curso: ${studentsList.length}');
      print('   - Capacidad por grupo: ${category.capacity}');
      
      // Calcular cantidad de grupos necesarios
      final totalGroups = (studentsList.length / category.capacity).ceil();
      print('   - Grupos a crear: $totalGroups');
      
      if (totalGroups == 0) {
        print('⚠️ No hay estudiantes para asignar grupos');
        return;
      }
      
      // Crear los grupos vacíos primero
      final createdGroups = <Map<String, dynamic>>[];
      
      for (int i = 1; i <= totalGroups; i++) {
        final groupData = {
          'name': 'Grupo $i',
          'category_id': '', // Se llenará después de obtener el ID de la categoría
        };
        
        // Necesitamos obtener el ID de la categoría recién creada
        final categories = await databaseService.read('categories');
        final createdCategory = categories
            .where((c) => c['name'] == category.name && c['course_id'] == courseId)
            .firstOrNull;
            
        if (createdCategory != null) {
          groupData['category_id'] = createdCategory['_id'];
        }
        
        await databaseService.insert('groups', [groupData]);
        
        // Obtener el grupo recién creado
        final groups = await databaseService.read('groups');
        final createdGroup = groups
            .where((g) => g['name'] == 'Grupo $i' && g['category_id'] == createdCategory?['_id'])
            .firstOrNull;
            
        if (createdGroup != null) {
          createdGroups.add(createdGroup);
        }
        
        print('✅ Grupo creado: Grupo $i');
      }
      
      // Asignar estudiantes según el tipo de categoría
      if (category.type == 'aleatorio') {
        await _assignStudentsRandomly(studentsList, createdGroups, category.capacity, databaseService);
      } else if (category.type == 'eleccion') {
        print('📝 Grupos creados vacíos para elección de estudiantes');
        // Los grupos quedan vacíos para que los estudiantes elijan
      }
      
    } catch (e) {
      print('❌ Error creando grupos automáticamente: $e');
      Get.snackbar(
        'Advertencia',
        'La categoría se creó pero hubo un error creando los grupos: $e',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
  
  /// Asigna estudiantes aleatoriamente a los grupos
  Future<void> _assignStudentsRandomly(
    List<Map<String, dynamic>> students,
    List<Map<String, dynamic>> groups,
    int capacity,
    RobleDatabaseService databaseService,
  ) async {
    final shuffledStudents = List<Map<String, dynamic>>.from(students)..shuffle();
    int currentGroupIndex = 0;
    int studentsInCurrentGroup = 0;
    
    print('🎲 Asignando estudiantes aleatoriamente...');
    
    for (final student in shuffledStudents) {
      // Si el grupo actual está lleno, pasar al siguiente
      if (studentsInCurrentGroup >= capacity) {
        currentGroupIndex++;
        studentsInCurrentGroup = 0;
      }
      
      // Si no hay más grupos disponibles, salir del bucle
      if (currentGroupIndex >= groups.length) {
        print('⚠️ No hay más grupos disponibles para asignar estudiante ${student['username']}');
        break;
      }
      
      final currentGroup = groups[currentGroupIndex];
      
      // Crear membresía de grupo
      final memberData = {
        'group_id': currentGroup['_id'],
        'student_id': student['uuid'] ?? student['_id'],
      };
      
      await databaseService.insert('group_members', [memberData]);
      studentsInCurrentGroup++;
      
      print('👥 ${student['username']} asignado a ${currentGroup['name']}');
    }
    
    print('✅ Asignación aleatoria completada');
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    capacityCtrl.dispose();
    super.onClose();
  }
}
