import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';
import '../usecase.dart';

class UpdateTransactionUseCase
    extends UseCase<TransactionEntity, TransactionEntity> {
  final TransactionRepository _repo;
  UpdateTransactionUseCase(this._repo);

  @override
  Future<Either<Failure, TransactionEntity>> call(TransactionEntity params) =>
      _repo.updateTransaction(params);
}
