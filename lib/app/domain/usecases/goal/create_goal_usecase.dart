import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/goal_repository.dart';
import '../../entities/goal_entity.dart';
import '../usecase.dart';

class CreateGoalUseCase extends UseCase<GoalEntity, CreateGoalParams> {
  final GoalRepository _repo;
  CreateGoalUseCase(this._repo);

  @override
  Future<Either<Failure, GoalEntity>> call(CreateGoalParams p) =>
      _repo.createGoal(
        userId: p.userId,
        walletId: p.walletId,
        name: p.name,
        iconName: p.iconName,
        colorHex: p.colorHex,
        targetAmount: p.targetAmount,
        deadline: p.deadline,
        note: p.note,
      );
}

class CreateGoalParams extends Equatable {
  final String userId;
  final String? walletId;
  final String name;
  final String iconName;
  final String colorHex;
  final double targetAmount;
  final DateTime? deadline;
  final String? note;

  const CreateGoalParams({
    required this.userId,
    this.walletId,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.targetAmount,
    this.deadline,
    this.note,
  });

  @override
  List<Object?> get props => [userId, name, targetAmount];
}
