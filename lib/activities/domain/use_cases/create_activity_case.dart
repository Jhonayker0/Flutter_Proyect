import '../models/activity.dart';
import '../repositories/activity_repository.dart';

class CreateActivity {
  final ActivityRepository repo;
  CreateActivity(this.repo);

  Future<void> call(Activity activity) => repo.create(activity);
}
