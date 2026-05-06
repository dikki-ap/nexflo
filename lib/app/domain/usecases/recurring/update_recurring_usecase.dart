import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/recurring_transaction_entity.dart';
import '../../repositories/recurring_transaction_repository.dart';
import '../usecase.dart';

class UpdateRecurringUseCase
    extends UseCase<RecurringTransactionEntity, RecurringTransactionEntity> {
  final RecurringTransactionRepository _repo;
  UpdateRecurringUseCase(this._repo);

  @override
  Future<Either<Failure, RecurringTransactionEntity>> call(
          RecurringTransactionEntity entity) =>
      _repo.update(entity);
}
