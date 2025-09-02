import 'package:flutter_application/domain/models/activity.dart';

abstract class ActivityRepository {
  Future<void> create(Activity activity);
}
