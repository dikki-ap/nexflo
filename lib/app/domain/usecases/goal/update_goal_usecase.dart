import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/goal_repository.dart';
import '../../entities/goal_entity.dart';
import '../usecase.dart';

class UpdateGoalUseCase extends UseCase<GoalEntity, GoalEntity> {
  final GoalRepository _repo;
  UpdateGoalUseCase(this._repo);

  @override
  Future<Either<Failure, GoalEntity>> call(GoalEntity params) =>
      _repo.updateGoal(params);
}
