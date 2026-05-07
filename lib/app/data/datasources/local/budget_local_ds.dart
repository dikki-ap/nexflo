import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/enums/budget_period.dart';
import '../../models/budget_model.dart';
import '../../../domain/entities/budget_entity.dart';

class BudgetLocalDataSource {
  final AppDatabase _db;
  BudgetLocalDataSource(this._db);

  Future<List<BudgetModel>> getAllByUserId(String userId) async {
    try {
      final rows = await (_db.select(_db.budgets)
            ..where((b) => b.userId.equals(userId))
            ..where((b) => b.deletedAt.isNull())
            ..orderBy([(b) => OrderingTerm.asc(b.createdAt)]))
          .get();
      return rows.map(BudgetModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get budgets: $e');
    }
  }

  Future<BudgetModel> insert(BudgetModel model) async {
    try {
      await _db.into(_db.budgets).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create budget: $e');
    }
  }

  Future<BudgetModel> update(BudgetEntity budget) async {
    try {
      final model = BudgetModel(
        id: budget.id,
        userId: budget.userId,
        name: budget.name,
        amount: budget.amount,
        period: budget.period,
        categoryId: budget.categoryId,
        walletId: budget.walletId,
        isAllCategories: budget.isAllCategories,
        rollover: budget.rollover,
        alertAtPercent: budget.alertAtPercent,
        createdAt: budget.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: budget.deletedAt,
        syncStatus: 'pending',
      );
      await (_db.update(_db.budgets)..where((b) => b.id.equals(budget.id)))
          .write(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update budget: $e');
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await (_db.update(_db.budgets)..where((b) => b.id.equals(id))).write(
        BudgetsCompanion(
          deletedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to delete budget: $e');
    }
  }

  Future<double> getSpentAmount({
    required String userId,
    required BudgetEntity budget,
  }) async {
    try {
      final (start, end) = _getPeriodRange(budget.period);
      var query = _db.select(_db.transactions)
        ..where((t) => t.userId.equals(userId))
        ..where((t) => t.type.equals('expense'))
        ..where((t) => t.date.isBetweenValues(start, end))
        ..where((t) => t.deletedAt.isNull());
      final rows = await query.get();
      var filtered = rows.toList();
      final catIds = budget.categoryIds;
      final walIds = budget.walletIds;
      if (!budget.isAllCategories && catIds.isNotEmpty) {
        filtered = filtered.where((t) => catIds.contains(t.categoryId)).toList();
      }
      if (walIds.isNotEmpty) {
        filtered = filtered.where((t) => walIds.contains(t.walletId)).toList();
      }
      return filtered.fold<double>(0.0, (s, t) => s + t.amount);
    } catch (e) {
      throw LocalDatabaseException('Failed to get spent amount: $e');
    }
  }

  Future<double> getPreviousPeriodSpent({
    required String userId,
    required BudgetEntity budget,
  }) async {
    try {
      final (start, end) = _getPreviousPeriodRange(budget.period);
      var query = _db.select(_db.transactions)
        ..where((t) => t.userId.equals(userId))
        ..where((t) => t.type.equals('expense'))
        ..where((t) => t.date.isBetweenValues(start, end))
        ..where((t) => t.deletedAt.isNull());
      final rows = await query.get();
      var filtered = rows.toList();
      final catIds = budget.categoryIds;
      final walIds = budget.walletIds;
      if (!budget.isAllCategories && catIds.isNotEmpty) {
        filtered = filtered.where((t) => catIds.contains(t.categoryId)).toList();
      }
      if (walIds.isNotEmpty) {
        filtered = filtered.where((t) => walIds.contains(t.walletId)).toList();
      }
      return filtered.fold<double>(0.0, (s, t) => s + t.amount);
    } catch (e) {
      throw LocalDatabaseException('Failed to get previous period spent: $e');
    }
  }

  (DateTime, DateTime) _getPreviousPeriodRange(BudgetPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case BudgetPeriod.monthly:
        return (
          DateTime(now.year, now.month - 1, 1),
          DateTime(now.year, now.month, 1),
        );
      case BudgetPeriod.weekly:
        final start = DateTime(
            now.year, now.month, now.day - (now.weekday - 1) - 7);
        return (start, start.add(const Duration(days: 7)));
      case BudgetPeriod.yearly:
        return (DateTime(now.year - 1, 1, 1), DateTime(now.year, 1, 1));
    }
  }

  (DateTime, DateTime) _getPeriodRange(BudgetPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case BudgetPeriod.monthly:
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 1),
        );
      case BudgetPeriod.weekly:
        final start = DateTime(
            now.year, now.month, now.day - (now.weekday - 1));
        return (start, start.add(const Duration(days: 7)));
      case BudgetPeriod.yearly:
        return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
    }
  }
}
