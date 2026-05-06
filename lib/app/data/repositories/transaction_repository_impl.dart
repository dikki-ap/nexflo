import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/enums/filter_period.dart';
import '../../core/enums/transaction_type.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/transaction_local_ds.dart';
import '../datasources/local/wallet_local_ds.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _local;
  final WalletLocalDataSource? _walletLocal;

  /// [walletLocal] is optional. When provided, wallet balances are updated
  /// atomically with every create / update / delete. Omit it for read-only
  /// repositories (e.g. DashboardController) or when the caller manages
  /// balance separately (e.g. WalletController adjust-balance flow).
  TransactionRepositoryImpl(this._local, [this._walletLocal]);

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
    bool skipBalanceUpdate = false,
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
      final result = await _local.insert(model);
      if (!skipBalanceUpdate && _walletLocal != null) {
        await _applyBalance(type, walletId, toWalletId, amount,
            isReversal: false);
      }
      return Right(result);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
      TransactionEntity transaction) async {
    try {
      if (_walletLocal != null) {
        // Reverse old transaction's balance effect.
        final old = await _local.getById(transaction.id);
        await _applyBalance(
            old.type.value, old.walletId, old.toWalletId, old.amount,
            isReversal: true);
        // Apply new transaction's balance effect.
        await _applyBalance(transaction.type.value, transaction.walletId,
            transaction.toWalletId, transaction.amount,
            isReversal: false);
      }
      return Right(await _local.update(transaction));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      if (_walletLocal != null) {
        // Reverse the transaction's balance effect before soft-deleting.
        final tx = await _local.getById(id);
        await _applyBalance(
            tx.type.value, tx.walletId, tx.toWalletId, tx.amount,
            isReversal: true);
      }
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

  /// Applies or reverses a transaction's effect on wallet balance(s).
  Future<void> _applyBalance(
    String type,
    String walletId,
    String? toWalletId,
    double amount, {
    required bool isReversal,
  }) async {
    final wallet = await _walletLocal!.getById(walletId);
    if (type == 'expense') {
      final newBal =
          isReversal ? wallet.balance + amount : wallet.balance - amount;
      await _walletLocal!.updateBalance(walletId, newBal);
    } else if (type == 'income') {
      final newBal =
          isReversal ? wallet.balance - amount : wallet.balance + amount;
      await _walletLocal!.updateBalance(walletId, newBal);
    } else if (type == 'transfer' && toWalletId != null) {
      final toWallet = await _walletLocal!.getById(toWalletId);
      final fromNew =
          isReversal ? wallet.balance + amount : wallet.balance - amount;
      final toNew =
          isReversal ? toWallet.balance - amount : toWallet.balance + amount;
      await _walletLocal!.updateBalance(walletId, fromNew);
      await _walletLocal!.updateBalance(toWalletId, toNew);
    }
  }
}
