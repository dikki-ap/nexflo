import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/debt_repository.dart';
import '../../entities/debt_payment_entity.dart';
import '../usecase.dart';

class GetDebtPaymentsUseCase
    extends UseCase<List<DebtPaymentEntity>, GetPaymentsParams> {
  final DebtRepository _repo;
  GetDebtPaymentsUseCase(this._repo);

  @override
  Future<Either<Failure, List<DebtPaymentEntity>>> call(
          GetPaymentsParams params) =>
      _repo.getPayments(params.debtId);
}

class GetPaymentsParams extends Equatable {
  final String debtId;
  const GetPaymentsParams(this.debtId);

  @override
  List<Object> get props => [debtId];
}
