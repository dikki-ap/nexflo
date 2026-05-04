import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/enums/filter_period.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../core/utils/date_helper.dart';
import '../../models/transaction_model.dart';
import '../../../domain/entities/transaction_entity.dart';

class TransactionLocalDataSource {
  final AppDatabase _db;
  TransactionLocalDataSource(this._db);

  Future<List<TransactionModel>> getByFilter({
    required String userId,
    required FilterPeriod period,
    String? walletId,
    String? categoryId,
    TransactionType? type,
    String? searchQuery,
    DateTime? customStart,
    DateTime? customEnd,
    int cutoffDate = 1,
  }) async {
    try {
      final (rangeStart, rangeEnd) =
          _getRange(period, cutoffDate, customStart, customEnd);
      var query = _db.select(_db.transactions)
        ..where((t) => t.userId.equals(userId))
        ..where((t) => t.deletedAt.isNull())
        ..where((t) => t.date.isBiggerOrEqualValue(rangeStart))
        ..where((t) => t.date.isSmallerOrEqualValue(rangeEnd));

      if (walletId != null) {
        query = query..where((t) => t.walletId.equals(walletId));
      }
      if (categoryId != null) {
        query = query..where((t) => t.categoryId.equals(categoryId));
      }
      if (type != null) {
        query = query..where((t) => t.type.equals(type.value));
      }

      query = query
        ..orderBy([(t) => OrderingTerm.desc(t.date)]);

      final rows = await query.get();
      var models = rows.map(TransactionModel.fromDrift).toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        models = models
            .where((t) => t.note?.toLowerCase().contains(q) ?? false)
            .toList();
      }

      return models;
    } catch (e) {
      throw LocalDatabaseException('Failed to get transactions: $e');
    }
  }

  Future<TransactionModel> getById(String id) async {
    try {
      final row = await (_db.select(_db.transactions)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      return TransactionModel.fromDrift(row);
    } catch (e) {
      throw LocalDatabaseException('Failed to get transaction: $e');
    }
  }

  Future<TransactionModel> insert(TransactionModel model) async {
    try {
      await _db.into(_db.transactions).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create transaction: $e');
    }
  }

  Future<TransactionModel> update(TransactionEntity tx) async {
    try {
      final model = TransactionModel(
        id: tx.id,
        userId: tx.userId,
        walletId: tx.walletId,
        toWalletId: tx.toWalletId,
        categoryId: tx.categoryId,
        subcategoryId: tx.subcategoryId,
        type: tx.type,
        amount: tx.amount,
        originalAmount: tx.originalAmount,
        originalCurrency: tx.originalCurrency,
        exchangeRate: tx.exchangeRate,
        note: tx.note,
        date: tx.date,
        receiptImagePath: tx.receiptImagePath,
        isRecurring: tx.isRecurring,
        recurringId: tx.recurringId,
        createdAt: tx.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: tx.deletedAt,
        syncStatus: 'pending',
        version: tx.version + 1,
      );
      await (_db.update(_db.transactions)..where((t) => t.id.equals(tx.id)))
          .write(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update transaction: $e');
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await (_db.update(_db.transactions)..where((t) => t.id.equals(id)))
          .write(TransactionsCompanion(
        deletedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ));
    } catch (e) {
      throw LocalDatabaseException('Failed to delete transaction: $e');
    }
  }

  Future<Map<String, double>> getSummary({
    required String userId,
    required FilterPeriod period,
    DateTime? customStart,
    DateTime? customEnd,
    int cutoffDate = 1,
  }) async {
    try {
      final (rStart, rEnd) =
          _getRange(period, cutoffDate, customStart, customEnd);
      final rows = await (_db.select(_db.transactions)
            ..where((t) => t.userId.equals(userId))
            ..where((t) => t.deletedAt.isNull())
            ..where((t) => t.date.isBiggerOrEqualValue(rStart))
            ..where((t) => t.date.isSmallerOrEqualValue(rEnd))
            ..where((t) => t.type.isNotValue('transfer')))
          .get();

      double income = 0;
      double expense = 0;
      for (final row in rows) {
        if (row.type == 'income') {
          income += row.amount;
        } else {
          expense += row.amount;
        }
      }
      return {'income': income, 'expense': expense};
    } catch (e) {
      throw LocalDatabaseException('Failed to get summary: $e');
    }
  }

  (DateTime, DateTime) _getRange(
    FilterPeriod period,
    int cutoffDate,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();
    switch (period) {
      case FilterPeriod.thisMonth:
        return DateHelper.getThisMonthRange(cutoffDate);
      case FilterPeriod.lastMonth:
        return DateHelper.getLastMonthRange(cutoffDate);
      case FilterPeriod.oneMonth:
        return (now.subtract(const Duration(days: 30)), now);
      case FilterPeriod.threeMonths:
        return (now.subtract(const Duration(days: 90)), now);
      case FilterPeriod.sixMonths:
        return (now.subtract(const Duration(days: 180)), now);
      case FilterPeriod.oneYear:
        return (DateTime(now.year - 1, now.month, now.day), now);
      case FilterPeriod.threeYears:
        return (DateTime(now.year - 3, now.month, now.day), now);
      case FilterPeriod.fiveYears:
        return (DateTime(now.year - 5, now.month, now.day), now);
      case FilterPeriod.allTime:
        return (DateTime(2000), now);
      case FilterPeriod.custom:
        return (customStart ?? DateTime(2000), customEnd ?? now);
    }
  }
}
