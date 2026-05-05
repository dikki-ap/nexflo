import 'package:dartz/dartz.dart';
import '../entities/budget_entity.dart';
import '../../core/errors/failures.dart';

abstract class BudgetRepository {
  Future<Either<Failure, List<BudgetEntity>>> getAllBudgets(String userId);
  Future<Either<Failure, BudgetEntity>> createBudget({
    required String userId,
    required String name,
    required double amount,
    required String period,
    String? categoryId,
    String? walletId,
    required bool isAllCategories,
    required bool rollover,
    required int alertAtPercent,
  });
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget);
  Future<Either<Failure, void>> deleteBudget(String id);
}
