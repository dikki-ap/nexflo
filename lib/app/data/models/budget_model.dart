import 'package:drift/drift.dart' show Value;
import '../../core/enums/budget_period.dart';
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/budget_entity.dart';
import '../database/app_database.dart';

class BudgetModel extends BudgetEntity {
  const BudgetModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.period,
    super.categoryId,
    super.walletId,
    required super.isAllCategories,
    required super.rollover,
    required super.alertAtPercent,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });

  factory BudgetModel.fromDrift(Budget b) => BudgetModel(
        id: b.id,
        userId: b.userId,
        name: b.name,
        amount: b.amount,
        period: BudgetPeriod.fromValue(b.period),
        categoryId: b.categoryId,
        walletId: b.walletId,
        isAllCategories: b.isAllCategories,
        rollover: b.rollover,
        alertAtPercent: b.alertAtPercent,
        createdAt: b.createdAt,
        updatedAt: b.updatedAt,
        deletedAt: b.deletedAt,
        syncStatus: b.syncStatus,
      );

  static BudgetModel create({
    required String userId,
    required String name,
    required double amount,
    required String period,
    String? categoryId,
    String? walletId,
    required bool isAllCategories,
    required bool rollover,
    required int alertAtPercent,
  }) {
    final now = DateTime.now();
    return BudgetModel(
      id: UuidHelper.generate(),
      userId: userId,
      name: name,
      amount: amount,
      period: BudgetPeriod.fromValue(period),
      categoryId: categoryId,
      walletId: walletId,
      isAllCategories: isAllCategories,
      rollover: rollover,
      alertAtPercent: alertAtPercent,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
  }

  BudgetsCompanion toCompanion() => BudgetsCompanion(
        id: Value(id),
        userId: Value(userId),
        name: Value(name),
        amount: Value(amount),
        period: Value(period.value),
        categoryId: Value(categoryId),
        walletId: Value(walletId),
        isAllCategories: Value(isAllCategories),
        rollover: Value(rollover),
        alertAtPercent: Value(alertAtPercent),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
        syncStatus: Value(syncStatus),
      );

  BudgetModel copyWith({
    String? name,
    double? amount,
    BudgetPeriod? period,
    String? categoryId,
    String? walletId,
    bool? isAllCategories,
    bool? rollover,
    int? alertAtPercent,
    DateTime? deletedAt,
  }) =>
      BudgetModel(
        id: id,
        userId: userId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        period: period ?? this.period,
        categoryId: categoryId ?? this.categoryId,
        walletId: walletId ?? this.walletId,
        isAllCategories: isAllCategories ?? this.isAllCategories,
        rollover: rollover ?? this.rollover,
        alertAtPercent: alertAtPercent ?? this.alertAtPercent,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        deletedAt: deletedAt ?? this.deletedAt,
        syncStatus: 'pending',
      );
}
