import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/transaction_repository.dart';
import '../usecase.dart';

class DeleteTransactionUseCase extends UseCase<void, DeleteTransactionParams> {
  final TransactionRepository _repo;
  DeleteTransactionUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) =>
      _repo.deleteTransaction(params.id);
}

class DeleteTransactionParams extends Equatable {
  final String id;
  const DeleteTransactionParams(this.id);

  @override
  List<Object?> get props => [id];
}
