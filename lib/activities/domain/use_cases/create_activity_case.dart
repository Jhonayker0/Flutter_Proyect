import '../models/activity.dart';
import '../repositories/activity_repository.dart';

class CreateActivity {
  final ActivityRepository repo;
  CreateActivity(this.repo);

  Future<void> call(Activity activity) async {
    print('📋 Caso de uso: Creando actividad "${activity.title}"');
    await repo.create(activity);
    print('✅ Caso de uso: Actividad creada exitosamente');
  }
}
