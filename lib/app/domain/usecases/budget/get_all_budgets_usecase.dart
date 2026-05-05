import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/budget_repository.dart';
import '../../entities/budget_entity.dart';
import '../usecase.dart';

class GetAllBudgetsUseCase
    extends UseCase<List<BudgetEntity>, GetAllBudgetsParams> {
  final BudgetRepository _repo;
  GetAllBudgetsUseCase(this._repo);

  @override
  Future<Either<Failure, List<BudgetEntity>>> call(
          GetAllBudgetsParams params) =>
      _repo.getAllBudgets(params.userId);
}

class GetAllBudgetsParams extends Equatable {
  final String userId;
  const GetAllBudgetsParams(this.userId);

  @override
  List<Object> get props => [userId];
}
