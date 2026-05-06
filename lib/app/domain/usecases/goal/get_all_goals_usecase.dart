import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/goal_repository.dart';
import '../../entities/goal_entity.dart';
import '../usecase.dart';

class GetAllGoalsUseCase extends UseCase<List<GoalEntity>, GetAllGoalsParams> {
  final GoalRepository _repo;
  GetAllGoalsUseCase(this._repo);

  @override
  Future<Either<Failure, List<GoalEntity>>> call(GetAllGoalsParams params) =>
      _repo.getAllGoals(params.userId);
}

class GetAllGoalsParams extends Equatable {
  final String userId;
  const GetAllGoalsParams(this.userId);

  @override
  List<Object> get props => [userId];
}
