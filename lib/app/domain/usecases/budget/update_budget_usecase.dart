import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/budget_repository.dart';
import '../../entities/budget_entity.dart';
import '../usecase.dart';

class UpdateBudgetUseCase extends UseCase<BudgetEntity, BudgetEntity> {
  final BudgetRepository _repo;
  UpdateBudgetUseCase(this._repo);

  @override
  Future<Either<Failure, BudgetEntity>> call(BudgetEntity params) =>
      _repo.updateBudget(params);
}
