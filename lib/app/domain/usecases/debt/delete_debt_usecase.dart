import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/debt_repository.dart';
import '../usecase.dart';

class DeleteDebtUseCase extends UseCase<void, DeleteDebtParams> {
  final DebtRepository _repo;
  DeleteDebtUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(DeleteDebtParams params) =>
      _repo.deleteDebt(params.id);
}

class DeleteDebtParams extends Equatable {
  final String id;
  const DeleteDebtParams(this.id);

  @override
  List<Object> get props => [id];
}
