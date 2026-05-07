import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/budget_repository.dart';
import '../../entities/budget_entity.dart';
import '../usecase.dart';

class CreateBudgetUseCase
    extends UseCase<BudgetEntity, CreateBudgetParams> {
  final BudgetRepository _repo;
  CreateBudgetUseCase(this._repo);

  @override
  Future<Either<Failure, BudgetEntity>> call(CreateBudgetParams p) =>
      _repo.createBudget(
        userId: p.userId,
        name: p.name,
        amount: p.amount,
        period: p.period,
        categoryId: p.categoryIds.isEmpty ? null : p.categoryIds.join(','),
        walletId: p.walletIds.isEmpty ? null : p.walletIds.join(','),
        isAllCategories: p.isAllCategories,
        rollover: p.rollover,
        alertAtPercent: p.alertAtPercent,
      );
}

class CreateBudgetParams extends Equatable {
  final String userId;
  final String name;
  final double amount;
  final String period;
  final List<String> categoryIds;
  final List<String> walletIds;
  final bool isAllCategories;
  final bool rollover;
  final int alertAtPercent;

  const CreateBudgetParams({
    required this.userId,
    required this.name,
    required this.amount,
    required this.period,
    this.categoryIds = const [],
    this.walletIds = const [],
    required this.isAllCategories,
    required this.rollover,
    required this.alertAtPercent,
  });

  @override
  List<Object?> get props => [userId, name, amount, period];
}
