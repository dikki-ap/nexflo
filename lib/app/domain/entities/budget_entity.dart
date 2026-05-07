import 'package:equatable/equatable.dart';
import '../../core/enums/budget_period.dart';

class BudgetEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final BudgetPeriod period;
  final String? categoryId;
  final String? walletId;
  final bool isAllCategories;
  final bool rollover;
  final int alertAtPercent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;

  const BudgetEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.period,
    this.categoryId,
    this.walletId,
    required this.isAllCategories,
    required this.rollover,
    required this.alertAtPercent,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });

  List<String> get walletIds =>
      walletId == null || walletId!.isEmpty ? [] : walletId!.split(',');

  List<String> get categoryIds =>
      categoryId == null || categoryId!.isEmpty ? [] : categoryId!.split(',');

  @override
  List<Object?> get props => [id, name, amount, period];
}
