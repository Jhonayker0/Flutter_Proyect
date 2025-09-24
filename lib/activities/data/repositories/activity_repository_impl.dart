import 'package:flutter_application/activities/data/services/activity_service.dart';
import 'package:flutter_application/activities/domain/models/activity.dart';
import 'package:flutter_application/activities/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityService service;
  ActivityRepositoryImpl(this.service);

  @override
  Future<void> create(Activity activity) async {
    print('🏛️ Repositorio: Creando actividad...');
    await service.postActivity(activity);
    print('✅ Repositorio: Actividad creada');
  }
}
