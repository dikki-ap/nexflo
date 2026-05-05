import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../core/enums/recurrence_type.dart';
import '../../models/recurring_transaction_model.dart';
import '../../../domain/entities/recurring_transaction_entity.dart';

class RecurringLocalDataSource {
  final AppDatabase _db;
  RecurringLocalDataSource(this._db);

  Future<List<RecurringTransactionModel>> getAllByUserId(String userId) async {
    try {
      final rows = await (_db.select(_db.recurringTransactions)
            ..where((r) => r.userId.equals(userId))
            ..where((r) => r.deletedAt.isNull())
            ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
          .get();
      return rows.map(RecurringTransactionModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get recurring transactions: $e');
    }
  }

  Future<List<RecurringTransactionModel>> getDueByUserId(String userId) async {
    try {
      final now = DateTime.now();
      final rows = await (_db.select(_db.recurringTransactions)
            ..where((r) => r.userId.equals(userId))
            ..where((r) => r.isActive.equals(true))
            ..where((r) => r.deletedAt.isNull())
            ..where((r) => r.nextDueDate.isSmallerOrEqualValue(now)))
          .get();
      return rows.map(RecurringTransactionModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get due recurring: $e');
    }
  }

  Future<RecurringTransactionModel> insert(
      RecurringTransactionModel model) async {
    try {
      await _db.into(_db.recurringTransactions).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create recurring: $e');
    }
  }

  Future<RecurringTransactionModel> update(
      RecurringTransactionEntity entity) async {
    try {
      final model = RecurringTransactionModel(
        id: entity.id,
        userId: entity.userId,
        walletId: entity.walletId,
        toWalletId: entity.toWalletId,
        categoryId: entity.categoryId,
        type: entity.type,
        amount: entity.amount,
        note: entity.note,
        recurrenceType: entity.recurrenceType,
        recurrenceInterval: entity.recurrenceInterval,
        startDate: entity.startDate,
        endDate: entity.endDate,
        nextDueDate: entity.nextDueDate,
        lastProcessedDate: entity.lastProcessedDate,
        isActive: entity.isActive,
        createdAt: entity.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: entity.deletedAt,
        syncStatus: 'pending',
      );
      await (_db.update(_db.recurringTransactions)
            ..where((r) => r.id.equals(entity.id)))
          .write(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update recurring: $e');
    }
  }

  Future<void> updateNextDue(
    String id,
    DateTime nextDueDate,
    DateTime lastProcessedDate,
    bool isActive,
  ) async {
    try {
      await (_db.update(_db.recurringTransactions)
            ..where((r) => r.id.equals(id)))
          .write(RecurringTransactionsCompanion(
        nextDueDate: Value(nextDueDate),
        lastProcessedDate: Value(lastProcessedDate),
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
    } catch (e) {
      throw LocalDatabaseException('Failed to update next due: $e');
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    try {
      await (_db.update(_db.recurringTransactions)
            ..where((r) => r.id.equals(id)))
          .write(RecurringTransactionsCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
    } catch (e) {
      throw LocalDatabaseException('Failed to toggle recurring: $e');
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await (_db.update(_db.recurringTransactions)
            ..where((r) => r.id.equals(id)))
          .write(RecurringTransactionsCompanion(
        deletedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
    } catch (e) {
      throw LocalDatabaseException('Failed to delete recurring: $e');
    }
  }
}
