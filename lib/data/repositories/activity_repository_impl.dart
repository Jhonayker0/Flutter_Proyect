
import 'package:flutter_application/data/services/activity_service.dart';
import 'package:flutter_application/domain/models/activity.dart';
import 'package:flutter_application/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityService service;
  ActivityRepositoryImpl(this.service);

  @override
  Future<void> create(Activity activity) async {
    final dto = {
      'title': activity.title,
      'description': activity.description,
      'dueDate': activity.dueDate.toIso8601String(),
      'type': activity.type,
      'courseId': activity.courseId,
    };
    await service.postActivity(dto);
  }
}
