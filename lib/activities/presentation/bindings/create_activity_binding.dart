import 'package:get/get.dart';
import 'package:flutter_application/core/services/roble_http_service.dart';
import 'package:flutter_application/core/services/roble_database_service.dart';
import 'package:flutter_application/core/services/roble_category_service.dart';
import '../../data/services/activity_service.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/use_cases/create_activity_case.dart';
import '../controllers/create_activity_controller.dart';

class CreateActivityBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 CreateActivityBinding - Configurando dependencias...');
    
    // Configurar servicios ROBLE
    final httpService = RobleHttpService();
    final databaseService = RobleDatabaseService(httpService);
    final categoryService = RobleCategoryService(databaseService);
    
    // Servicios de actividades
    final service = ActivityService(databaseService);
    final repo = ActivityRepositoryImpl(service);
    final useCase = CreateActivity(repo);
    
    print('🎮 Creando CreateActivityController...');
    Get.put(CreateActivityController(
      createActivityUC: useCase,
      categoryService: categoryService,
    ));
    print('✅ CreateActivityBinding - Dependencias configuradas');
  }
}
