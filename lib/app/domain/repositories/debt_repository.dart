import 'package:dartz/dartz.dart';
import '../entities/debt_entity.dart';
import '../entities/debt_payment_entity.dart';
import '../../core/errors/failures.dart';

abstract class DebtRepository {
  Future<Either<Failure, List<DebtEntity>>> getAllDebts(String userId);
  Future<Either<Failure, DebtEntity>> createDebt({
    required String userId,
    required String type,
    required String personName,
    required double amount,
    required String currencyCode,
    DateTime? deadline,
    String? note,
  });
  Future<Either<Failure, DebtEntity>> updateDebt(DebtEntity debt);
  Future<Either<Failure, void>> deleteDebt(String id);
  Future<Either<Failure, DebtEntity>> addPayment({
    required String debtId,
    required double amount,
    required DateTime date,
    String? note,
  });
  Future<Either<Failure, List<DebtPaymentEntity>>> getPayments(String debtId);
}
