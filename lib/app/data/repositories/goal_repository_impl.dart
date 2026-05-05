import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/local/goal_local_ds.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalLocalDataSource _local;
  GoalRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<GoalEntity>>> getAllGoals(String userId) async {
    try {
      return Right(await _local.getAllByUserId(userId));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GoalEntity>> createGoal({
    required String userId,
    String? walletId,
    required String name,
    required String iconName,
    required String colorHex,
    required double targetAmount,
    DateTime? deadline,
    String? note,
  }) async {
    try {
      final model = GoalModel.create(
        userId: userId,
        walletId: walletId,
        name: name,
        iconName: iconName,
        colorHex: colorHex,
        targetAmount: targetAmount,
        deadline: deadline,
        note: note,
      );
      return Right(await _local.insert(model));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GoalEntity>> updateGoal(GoalEntity goal) async {
    try {
      return Right(await _local.update(goal));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) async {
    try {
      await _local.softDelete(id);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GoalEntity>> allocate(
      String goalId, double newTotalAmount) async {
    try {
      return Right(await _local.updateAmount(goalId, newTotalAmount));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
