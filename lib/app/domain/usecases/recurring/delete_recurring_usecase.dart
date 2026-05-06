import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/recurring_transaction_repository.dart';
import '../usecase.dart';

class DeleteRecurringUseCase extends UseCase<void, DeleteRecurringParams> {
  final RecurringTransactionRepository _repo;
  DeleteRecurringUseCase(this._repo);

  @override
  Future<Either<Failure, void>> call(DeleteRecurringParams params) =>
      _repo.delete(params.id);
}

class DeleteRecurringParams extends Equatable {
  final String id;
  const DeleteRecurringParams(this.id);

  @override
  List<Object?> get props => [id];
}
