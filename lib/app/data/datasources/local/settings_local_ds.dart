import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../models/settings_model.dart';
import '../../../core/errors/exceptions.dart';

class SettingsLocalDataSource {
  final AppDatabase _db;
  SettingsLocalDataSource(this._db);

  Future<SettingsModel?> getByUserId(String userId) async {
    try {
      final query = _db.select(_db.settings)
        ..where((s) => s.userId.equals(userId));
      final row = await query.getSingleOrNull();
      return row != null ? SettingsModel.fromDrift(row) : null;
    } catch (e) {
      throw LocalDatabaseException('Failed to get settings: $e');
    }
  }

  Future<SettingsModel> createDefault(String userId) async {
    try {
      final model = SettingsModel.defaultFor(userId);
      await _db.into(_db.settings).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create default settings: $e');
    }
  }

  Future<SettingsModel> update(SettingsModel model) async {
    try {
      final companion = model.toCompanion().copyWith(
            updatedAt: Value(DateTime.now()),
          );
      await (_db.update(_db.settings)
            ..where((s) => s.userId.equals(model.userId)))
          .write(companion);
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update settings: $e');
    }
  }
}
