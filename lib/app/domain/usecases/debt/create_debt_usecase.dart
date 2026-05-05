import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/debt_repository.dart';
import '../../entities/debt_entity.dart';
import '../usecase.dart';

class CreateDebtUseCase extends UseCase<DebtEntity, CreateDebtParams> {
  final DebtRepository _repo;
  CreateDebtUseCase(this._repo);

  @override
  Future<Either<Failure, DebtEntity>> call(CreateDebtParams p) =>
      _repo.createDebt(
        userId: p.userId,
        type: p.type,
        personName: p.personName,
        amount: p.amount,
        currencyCode: p.currencyCode,
        deadline: p.deadline,
        note: p.note,
      );
}

class CreateDebtParams extends Equatable {
  final String userId;
  final String type;
  final String personName;
  final double amount;
  final String currencyCode;
  final DateTime? deadline;
  final String? note;

  const CreateDebtParams({
    required this.userId,
    required this.type,
    required this.personName,
    required this.amount,
    required this.currencyCode,
    this.deadline,
    this.note,
  });

  @override
  List<Object?> get props => [userId, personName, amount];
}
