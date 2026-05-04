import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../models/user_model.dart';
import '../../../core/errors/exceptions.dart';

class UserLocalDataSource {
  final AppDatabase _db;
  UserLocalDataSource(this._db);

  Future<UserModel?> getUserByGoogleId(String googleId) async {
    try {
      final query = _db.select(_db.users)
        ..where((u) => u.googleId.equals(googleId));
      final row = await query.getSingleOrNull();
      return row != null ? UserModel.fromDrift(row) : null;
    } catch (e) {
      throw LocalDatabaseException('Failed to get user: $e');
    }
  }

  Future<UserModel?> getUserById(String id) async {
    try {
      final query = _db.select(_db.users)
        ..where((u) => u.id.equals(id));
      final row = await query.getSingleOrNull();
      return row != null ? UserModel.fromDrift(row) : null;
    } catch (e) {
      throw LocalDatabaseException('Failed to get user: $e');
    }
  }

  Future<UserModel> upsertUser(UsersCompanion companion) async {
    try {
      await _db.into(_db.users).insertOnConflictUpdate(companion);
      final row = await (_db.select(_db.users)
            ..where((u) => u.id.equals(companion.id.value)))
          .getSingle();
      return UserModel.fromDrift(row);
    } catch (e) {
      throw LocalDatabaseException('Failed to upsert user: $e');
    }
  }

  Future<void> updateSheetsId(String userId, String sheetsId) async {
    try {
      await (_db.update(_db.users)..where((u) => u.id.equals(userId)))
          .write(UsersCompanion(sheetsId: Value(sheetsId)));
    } catch (e) {
      throw LocalDatabaseException('Failed to update sheets ID: $e');
    }
  }
}
