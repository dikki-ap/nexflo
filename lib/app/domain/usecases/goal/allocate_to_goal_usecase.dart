import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/goal_repository.dart';
import '../../entities/goal_entity.dart';
import '../usecase.dart';

class AllocateToGoalUseCase extends UseCase<GoalEntity, AllocateParams> {
  final GoalRepository _repo;
  AllocateToGoalUseCase(this._repo);

  @override
  Future<Either<Failure, GoalEntity>> call(AllocateParams params) =>
      _repo.allocate(params.goalId, params.amount);
}

class AllocateParams extends Equatable {
  final String goalId;
  final double amount;
  const AllocateParams({required this.goalId, required this.amount});

  @override
  List<Object> get props => [goalId, amount];
}
