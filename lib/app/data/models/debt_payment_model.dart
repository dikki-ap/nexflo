import 'package:drift/drift.dart' show Value;
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/debt_payment_entity.dart';
import '../database/app_database.dart';

class DebtPaymentModel extends DebtPaymentEntity {
  const DebtPaymentModel({
    required super.id,
    required super.debtId,
    required super.amount,
    required super.date,
    super.note,
    required super.createdAt,
    required super.syncStatus,
  });

  factory DebtPaymentModel.fromDrift(DebtPayment p) => DebtPaymentModel(
        id: p.id,
        debtId: p.debtId,
        amount: p.amount,
        date: p.date,
        note: p.note,
        createdAt: p.createdAt,
        syncStatus: p.syncStatus,
      );

  static DebtPaymentModel create({
    required String debtId,
    required double amount,
    required DateTime date,
    String? note,
  }) {
    final now = DateTime.now();
    return DebtPaymentModel(
      id: UuidHelper.generate(),
      debtId: debtId,
      amount: amount,
      date: date,
      note: note,
      createdAt: now,
      syncStatus: 'pending',
    );
  }

  DebtPaymentsCompanion toCompanion() => DebtPaymentsCompanion(
        id: Value(id),
        debtId: Value(debtId),
        amount: Value(amount),
        date: Value(date),
        note: Value(note),
        createdAt: Value(createdAt),
        syncStatus: Value(syncStatus),
      );
}
