import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/debt_entity.dart';
import '../../domain/entities/debt_payment_entity.dart';
import '../../domain/repositories/debt_repository.dart';
import '../datasources/local/debt_local_ds.dart';
import '../models/debt_model.dart';

class DebtRepositoryImpl implements DebtRepository {
  final DebtLocalDataSource _local;
  DebtRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<DebtEntity>>> getAllDebts(String userId) async {
    try {
      return Right(await _local.getAllByUserId(userId));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DebtEntity>> createDebt({
    required String userId,
    required String type,
    required String personName,
    required double amount,
    required String currencyCode,
    DateTime? deadline,
    String? note,
  }) async {
    try {
      final model = DebtModel.create(
        userId: userId,
        type: type,
        personName: personName,
        amount: amount,
        currencyCode: currencyCode,
        deadline: deadline,
        note: note,
      );
      return Right(await _local.insert(model));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DebtEntity>> updateDebt(DebtEntity debt) async {
    try {
      return Right(await _local.update(debt));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDebt(String id) async {
    try {
      await _local.softDelete(id);
      return const Right(null);
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, DebtEntity>> addPayment({
    required String debtId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      return Right(await _local.addPayment(
        debtId: debtId,
        amount: amount,
        date: date,
        note: note,
      ));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<DebtPaymentEntity>>> getPayments(
      String debtId) async {
    try {
      return Right(await _local.getPayments(debtId));
    } on LocalDatabaseException catch (e) {
      return Left(LocalDatabaseFailure(e.message));
    }
  }
}
