import 'package:flutter_application/domain/models/activity.dart';

abstract class ActivityRepository {
  Future<void> create(Activity activity);
  Future<List<Activity>> getActivitiesByCourse(int courseId);
  Future<List<Activity>> getActivitiesByCategory(int categoryId);
  Future<void> update(Activity activity);
  Future<void> delete(int id);
  Future<List<Map<String, dynamic>>> getCategoriesByCourse(int courseId);
}
