import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/enums/filter_period.dart';
import '../../core/enums/transaction_type.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/transaction_local_ds.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _local;
  TransactionRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    required FilterPeriod period,
    String? walletId,
    String? categoryId,
    TransactionType? type,
    String? searchQuery,
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    try {
      final results = await _local.getByFilter(
        userId: userId,
        period: period,
        walletId: walletId,
        categoryId: categoryId,
        type: type,
        searchQuery: searchQuery,
        customStart: customStart,
        customEnd: customEnd,
      );
      return Right(results);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getById(String id) async {
    try {
      return Right(await _local.getById(id));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
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
  }) async {
    try {
      final model = TransactionModel.create(
        userId: userId,
        walletId: walletId,
        toWalletId: toWalletId,
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        type: type,
        amount: amount,
        originalAmount: originalAmount,
        originalCurrency: originalCurrency,
        exchangeRate: exchangeRate,
        note: note,
        date: date,
        receiptImagePath: receiptImagePath,
        isRecurring: isRecurring,
        recurringId: recurringId,
      );
      return Right(await _local.insert(model));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction) async {
    try {
      return Right(await _local.update(transaction));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await _local.softDelete(id);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getSummary({
    required String userId,
    required FilterPeriod period,
    DateTime? customStart,
    DateTime? customEnd,
  }) async {
    try {
      return Right(await _local.getSummary(
        userId: userId,
        period: period,
        customStart: customStart,
        customEnd: customEnd,
      ));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
