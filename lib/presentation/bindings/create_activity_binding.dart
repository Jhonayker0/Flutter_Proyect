import 'package:get/get.dart';
import '../../data/services/activity_service.dart';
import '../../data/repositories/activity_repository_impl.dart';
import '../../domain/use_cases/create_activity_case.dart';
import '../controllers/create_activity_controller.dart';

class CreateActivityBinding extends Bindings {
  @override
  void dependencies() {
    final service = ActivityService();
    final repo = ActivityRepositoryImpl(service);
    final useCase = CreateActivity(repo);
    Get.put(
      CreateActivityController(
        createActivityUC: useCase,
        activityRepository: repo,
      ),
    );
  }
}
