import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../errors/failures.dart';
import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_entity.dart';
import '../usecase.dart';

class CreateTransactionUseCase
    extends UseCase<TransactionEntity, CreateTransactionParams> {
  final TransactionRepository _repo;
  CreateTransactionUseCase(this._repo);

  @override
  Future<Either<Failure, TransactionEntity>> call(
          CreateTransactionParams params) =>
      _repo.createTransaction(
        userId: params.userId,
        walletId: params.walletId,
        toWalletId: params.toWalletId,
        categoryId: params.categoryId,
        subcategoryId: params.subcategoryId,
        type: params.type,
        amount: params.amount,
        originalAmount: params.originalAmount,
        originalCurrency: params.originalCurrency,
        exchangeRate: params.exchangeRate,
        note: params.note,
        date: params.date,
        receiptImagePath: params.receiptImagePath,
        isRecurring: params.isRecurring,
        recurringId: params.recurringId,
      );
}

class CreateTransactionParams extends Equatable {
  final String userId;
  final String walletId;
  final String? toWalletId;
  final String? categoryId;
  final String? subcategoryId;
  final String type;
  final double amount;
  final double? originalAmount;
  final String? originalCurrency;
  final double? exchangeRate;
  final String? note;
  final DateTime date;
  final String? receiptImagePath;
  final bool isRecurring;
  final String? recurringId;

  const CreateTransactionParams({
    required this.userId,
    required this.walletId,
    this.toWalletId,
    this.categoryId,
    this.subcategoryId,
    required this.type,
    required this.amount,
    this.originalAmount,
    this.originalCurrency,
    this.exchangeRate,
    this.note,
    required this.date,
    this.receiptImagePath,
    this.isRecurring = false,
    this.recurringId,
  });

  @override
  List<Object?> get props => [userId, walletId, type, amount, date];
}
