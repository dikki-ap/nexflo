import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/debt_repository.dart';
import '../../entities/debt_entity.dart';
import '../usecase.dart';

class AddDebtPaymentUseCase extends UseCase<DebtEntity, AddPaymentParams> {
  final DebtRepository _repo;
  AddDebtPaymentUseCase(this._repo);

  @override
  Future<Either<Failure, DebtEntity>> call(AddPaymentParams p) =>
      _repo.addPayment(
        debtId: p.debtId,
        amount: p.amount,
        date: p.date,
        note: p.note,
      );
}

class AddPaymentParams extends Equatable {
  final String debtId;
  final double amount;
  final DateTime date;
  final String? note;

  const AddPaymentParams({
    required this.debtId,
    required this.amount,
    required this.date,
    this.note,
  });

  @override
  List<Object?> get props => [debtId, amount, date];
}
