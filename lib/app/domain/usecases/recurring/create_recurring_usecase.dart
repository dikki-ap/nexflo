import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../entities/recurring_transaction_entity.dart';
import '../../repositories/recurring_transaction_repository.dart';
import '../usecase.dart';

class CreateRecurringUseCase
    extends UseCase<RecurringTransactionEntity, CreateRecurringParams> {
  final RecurringTransactionRepository _repo;
  CreateRecurringUseCase(this._repo);

  @override
  Future<Either<Failure, RecurringTransactionEntity>> call(
          CreateRecurringParams p) =>
      _repo.create(
        userId: p.userId,
        walletId: p.walletId,
        toWalletId: p.toWalletId,
        categoryId: p.categoryId,
        type: p.type,
        amount: p.amount,
        note: p.note,
        recurrenceType: p.recurrenceType,
        recurrenceInterval: p.recurrenceInterval,
        startDate: p.startDate,
        endDate: p.endDate,
      );
}

class CreateRecurringParams extends Equatable {
  final String userId;
  final String walletId;
  final String? toWalletId;
  final String? categoryId;
  final String type;
  final double amount;
  final String? note;
  final String recurrenceType;
  final int recurrenceInterval;
  final DateTime startDate;
  final DateTime? endDate;

  const CreateRecurringParams({
    required this.userId,
    required this.walletId,
    this.toWalletId,
    this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.recurrenceType,
    required this.recurrenceInterval,
    required this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, walletId, type, amount];
}
