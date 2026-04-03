import '../models/app_snapshot.dart';

abstract class PersistenceRepository {
  Future<AppSnapshot?> loadSnapshot();
  Future<void> saveSnapshot(AppSnapshot snapshot);
  Future<void> clear();
}
