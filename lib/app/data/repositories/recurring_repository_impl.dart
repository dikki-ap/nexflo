import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/recurring_transaction_entity.dart';
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../datasources/local/recurring_local_ds.dart';
import '../models/recurring_transaction_model.dart';

class RecurringRepositoryImpl implements RecurringTransactionRepository {
  final RecurringLocalDataSource _local;
  RecurringRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>> getAll(
      String userId) async {
    try {
      return Right(await _local.getAllByUserId(userId));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, RecurringTransactionEntity>> create({
    required String userId,
    required String walletId,
    String? toWalletId,
    String? categoryId,
    required String type,
    required double amount,
    String? note,
    required String recurrenceType,
    required int recurrenceInterval,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    try {
      final model = RecurringTransactionModel.create(
        userId: userId,
        walletId: walletId,
        toWalletId: toWalletId,
        categoryId: categoryId,
        type: type,
        amount: amount,
        note: note,
        recurrenceType: recurrenceType,
        recurrenceInterval: recurrenceInterval,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(await _local.insert(model));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, RecurringTransactionEntity>> update(
      RecurringTransactionEntity entity) async {
    try {
      return Right(await _local.update(entity));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _local.softDelete(id);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> toggleActive(String id, bool isActive) async {
    try {
      await _local.toggleActive(id, isActive);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
