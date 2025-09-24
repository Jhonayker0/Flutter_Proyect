import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/courses/domain/models/course.dart';

class RobleCourseService {
  final RobleDatabaseService _databaseService;
  static const String tableName = 'courses';

  RobleCourseService(this._databaseService);

  /// Obtener todos los cursos
  Future<List<Course>> getAllCourses({String? currentUserId}) async {
    try {
      final data = await _databaseService.read(tableName);
      return data
          .map(
            (courseMap) =>
                Course.fromRoble(courseMap, currentUserId: currentUserId),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo cursos: $e');
      rethrow;
    }
  }

  /// Obtener cursos donde el usuario es profesor
  /// CORREGIDO: Filtra en el cliente en lugar del servidor
  Future<List<Course>> getCoursesByProfessor(String professorId) async {
    try {
      // Obtener todos los cursos y filtrar en el cliente
      final data = await _databaseService.read(tableName);

      // Filtrar cursos donde professor_id coincide
      final filteredData = data.where((course) {
        return course['professor_id'] == professorId;
      }).toList();

      return filteredData
          .map(
            (courseMap) =>
                Course.fromRoble(courseMap, currentUserId: professorId),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo cursos del profesor: $e');
      rethrow;
    }
  }

  /// Obtener cursos donde el usuario está inscrito
  Future<List<Course>> getCoursesByStudent(String studentId) async {
    try {
      print('📚 Buscando cursos para estudiante: $studentId');

      // 1. Obtener enrollments del estudiante
      final enrollments = await _databaseService.read('enrollments');
      final studentEnrollments = enrollments
          .where((enrollment) => enrollment['student_id'] == studentId)
          .toList();

      print('📋 Enrollments encontrados: ${studentEnrollments.length}');

      if (studentEnrollments.isEmpty) {
        print('📚 Usuario $studentId no tiene enrollments');
        return [];
      }

      // 2. Extraer los course_ids
      final enrolledCourseIds = studentEnrollments
          .map<String>((enrollment) => enrollment['course_id'] as String)
          .toSet()
          .toList();

      print('🔍 Course IDs desde enrollments: $enrolledCourseIds');

      // 3. Obtener todos los cursos y filtrar
      final allCourses = await _databaseService.read(tableName);
      final enrolledCourses = allCourses
          .where((course) => enrolledCourseIds.contains(course['_id']))
          .toList();

      print(
        '✅ Cursos filtrados: ${enrolledCourses.length} de ${allCourses.length} totales',
      );

      return enrolledCourses
          .map(
            (courseMap) =>
                Course.fromRoble(courseMap, currentUserId: studentId),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo cursos del estudiante: $e');
      rethrow;
    }
  }

  /// Crear un nuevo curso
  Future<void> createCourse(Course course) async {
    try {
      print('🔄 Iniciando creación de curso...');
      print('📝 Datos del curso: ${course.toRoble()}');
      print('🗂️ Tabla destino: $tableName');
      
      // 1. Crear el curso
      await _databaseService.insert(tableName, [course.toRoble()]);
      print('✅ Curso creado exitosamente en ROBLE');
      
      // 2. Obtener el ID del curso recién creado
      // Necesitamos leer la tabla courses para obtener el ID del curso recién creado
      final allCourses = await _databaseService.read(tableName);
      final createdCourse = allCourses
          .where((c) => c['professor_id'] == course.professorId && c['title'] == course.title)
          .firstOrNull;
      
      if (createdCourse != null && createdCourse['_id'] != null) {
        final courseId = createdCourse['_id'] as String;
        print('🆔 ID del curso creado: $courseId');
        
        // 3. Crear enrollment del profesor automáticamente
        final professorEnrollment = {
          'student_id': course.professorId, // En enrollments, el campo se llama student_id pero puede ser profesor
          'course_id': courseId,
          'role': 'professor',
        };
        
        print('👨‍🏫 Creando enrollment del profesor: $professorEnrollment');
        await _databaseService.insert('enrollments', [professorEnrollment]);
        print('✅ Profesor añadido automáticamente a enrollments');
      } else {
        print('⚠️ No se pudo obtener el ID del curso creado, enrollment no creado');
      }
      
    } catch (e) {
      print('❌ Error creando curso: $e');
      print('🔍 Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  /// Actualizar un curso existente
  Future<void> updateCourse(String courseId, Course course) async {
    try {
      final updates = course.toRoble();
      updates.remove('_id'); // No actualizar el ID
      await _databaseService.update(tableName, courseId, updates);
    } catch (e) {
      print('❌ Error actualizando curso: $e');
      rethrow;
    }
  }

  /// Eliminar un curso
  Future<void> deleteCourse(String courseId) async {
    try {
      await _databaseService.delete(tableName, courseId);
    } catch (e) {
      print('❌ Error eliminando curso: $e');
      rethrow;
    }
  }

  /// Obtener un curso específico por ID
  Future<Course?> getCourseById(
    String courseId, {
    String? currentUserId,
  }) async {
    try {
      final data = await _databaseService.read(tableName);
      final courseData = data.firstWhere(
        (course) => course['_id'] == courseId,
        orElse: () => <String, dynamic>{},
      );

      if (courseData.isEmpty) return null;

      return Course.fromRoble(courseData, currentUserId: currentUserId);
    } catch (e) {
      print('❌ Error obteniendo curso por ID: $e');
      return null;
    }
  }
}
