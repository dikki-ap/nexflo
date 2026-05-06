import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../entities/recurring_transaction_entity.dart';
import '../../repositories/recurring_transaction_repository.dart';
import '../usecase.dart';

class GetRecurringUseCase
    extends UseCase<List<RecurringTransactionEntity>, GetRecurringParams> {
  final RecurringTransactionRepository _repo;
  GetRecurringUseCase(this._repo);

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>> call(
          GetRecurringParams params) =>
      _repo.getAll(params.userId);
}

class GetRecurringParams extends Equatable {
  final String userId;
  const GetRecurringParams(this.userId);

  @override
  List<Object?> get props => [userId];
}
