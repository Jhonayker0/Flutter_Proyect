
import 'package:flutter_application/data/services/activity_service.dart';
import 'package:flutter_application/domain/models/activity.dart';
import 'package:flutter_application/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityService service;
  ActivityRepositoryImpl(this.service);

  @override
  Future<void> create(Activity activity) async {
    final dto = {
      'name': activity.name,
      'description': activity.description,
      'deadline': activity.deadline?.toIso8601String(),
      'category': activity.category,
      'attachmentPath': activity.attachmentPath,
    };
    await service.postActivity(dto);
  }
}
