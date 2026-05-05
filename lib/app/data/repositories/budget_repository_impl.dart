import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/local/budget_local_ds.dart';
import '../models/budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource _local;
  BudgetRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<BudgetEntity>>> getAllBudgets(
      String userId) async {
    try {
      return Right(await _local.getAllByUserId(userId));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
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
  }) async {
    try {
      final model = BudgetModel.create(
        userId: userId,
        name: name,
        amount: amount,
        period: period,
        categoryId: categoryId,
        walletId: walletId,
        isAllCategories: isAllCategories,
        rollover: rollover,
        alertAtPercent: alertAtPercent,
      );
      return Right(await _local.insert(model));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> updateBudget(
      BudgetEntity budget) async {
    try {
      return Right(await _local.update(budget));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    try {
      await _local.softDelete(id);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
