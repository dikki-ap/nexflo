import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/budget_repository.dart';
import '../usecase.dart';

class DeleteBudgetUseCase extends UseCase<void, DeleteBudgetParams> {
  final BudgetRepository _repo;
  DeleteBudgetUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(DeleteBudgetParams params) =>
      _repo.deleteBudget(params.id);
}

class DeleteBudgetParams extends Equatable {
  final String id;
  const DeleteBudgetParams(this.id);

  @override
  List<Object> get props => [id];
}
