import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../entities/recurring_transaction_entity.dart';

abstract class RecurringTransactionRepository {
  Future<Either<Failure, List<RecurringTransactionEntity>>> getAll(String userId);
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
  });
  Future<Either<Failure, RecurringTransactionEntity>> update(
      RecurringTransactionEntity entity);
  Future<Either<Failure, void>> delete(String id);
  Future<Either<Failure, void>> toggleActive(String id, bool isActive);
}
