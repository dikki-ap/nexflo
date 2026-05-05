import 'package:dartz/dartz.dart';
import '../entities/goal_entity.dart';
import '../../core/errors/failures.dart';

abstract class GoalRepository {
  Future<Either<Failure, List<GoalEntity>>> getAllGoals(String userId);
  Future<Either<Failure, GoalEntity>> createGoal({
    required String userId,
    String? walletId,
    required String name,
    required String iconName,
    required String colorHex,
    required double targetAmount,
    DateTime? deadline,
    String? note,
  });
  Future<Either<Failure, GoalEntity>> updateGoal(GoalEntity goal);
  Future<Either<Failure, void>> deleteGoal(String id);
  Future<Either<Failure, GoalEntity>> allocate(String goalId, double amount);
}
