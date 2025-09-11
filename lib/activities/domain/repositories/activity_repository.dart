import 'package:flutter_application/activities/domain/models/activity.dart';

abstract class ActivityRepository {
  Future<void> create(Activity activity);
}







