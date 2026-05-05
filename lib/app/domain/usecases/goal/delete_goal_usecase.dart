import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/goal_repository.dart';
import '../usecase.dart';

class DeleteGoalUseCase extends UseCase<void, DeleteGoalParams> {
  final GoalRepository _repo;
  DeleteGoalUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(DeleteGoalParams params) =>
      _repo.deleteGoal(params.id);
}

class DeleteGoalParams extends Equatable {
  final String id;
  const DeleteGoalParams(this.id);

  @override
  List<Object> get props => [id];
}
