import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/enums/filter_period.dart';
import '../../core/enums/transaction_type.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    required FilterPeriod period,
    String? walletId,
    String? categoryId,
    TransactionType? type,
    String? searchQuery,
    DateTime? customStart,
    DateTime? customEnd,
  });

  Future<Either<Failure, TransactionEntity>> getById(String id);

  Future<Either<Failure, TransactionEntity>> createTransaction({
    required String userId,
    required String walletId,
    String? toWalletId,
    String? categoryId,
    String? subcategoryId,
    required String type,
    required double amount,
    double? originalAmount,
    String? originalCurrency,
    double? exchangeRate,
    String? note,
    required DateTime date,
    String? receiptImagePath,
    bool isRecurring = false,
    String? recurringId,
  });

  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction);

  Future<Either<Failure, void>> deleteTransaction(String id);

  Future<Either<Failure, Map<String, double>>> getSummary({
    required String userId,
    required FilterPeriod period,
    DateTime? customStart,
    DateTime? customEnd,
  });
}
