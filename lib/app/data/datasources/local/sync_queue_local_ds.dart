import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/uuid_helper.dart';

class SyncQueueLocalDataSource {
  final AppDatabase _db;
  SyncQueueLocalDataSource(this._db);

  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String actionType,
    required String payloadJson,
  }) async {
    try {
      final companion = SyncQueueCompanion.insert(
        id: UuidHelper.generate(),
        entityType: entityType,
        entityId: entityId,
        actionType: actionType,
        payloadJson: payloadJson,
      );
      await _db.into(_db.syncQueue).insert(
            companion,
            mode: InsertMode.insertOrReplace,
          );
    } catch (e) {
      throw LocalDatabaseException('Failed to enqueue sync item: $e');
    }
  }

  Future<List<SyncQueueData>> getPending() async {
    try {
      return await (_db.select(_db.syncQueue)
            ..where((q) => q.status.equals('pending'))
            ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
          .get();
    } catch (e) {
      throw LocalDatabaseException('Failed to get pending sync items: $e');
    }
  }

  Future<void> updateStatus(
    String id,
    String status, {
    String? errorMessage,
    int? retryCount,
  }) async {
    try {
      await (_db.update(_db.syncQueue)..where((q) => q.id.equals(id))).write(
        SyncQueueCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
          errorMessage:
              errorMessage != null ? Value(errorMessage) : const Value.absent(),
          retryCount:
              retryCount != null ? Value(retryCount) : const Value.absent(),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to update sync status: $e');
    }
  }

  Future<void> clearDone() async {
    try {
      await (_db.delete(_db.syncQueue)
            ..where((q) => q.status.equals('done')))
          .go();
    } catch (e) {
      throw LocalDatabaseException('Failed to clear done sync items: $e');
    }
  }

  Future<int> pendingCount() async {
    try {
      final items = await (_db.select(_db.syncQueue)
            ..where((q) => q.status.equals('pending')))
          .get();
      return items.length;
    } catch (e) {
      return 0;
    }
  }
}
