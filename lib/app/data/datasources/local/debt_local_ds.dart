import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/enums/debt_status.dart';
import '../../models/debt_model.dart';
import '../../models/debt_payment_model.dart';
import '../../../domain/entities/debt_entity.dart';

class DebtLocalDataSource {
  final AppDatabase _db;
  DebtLocalDataSource(this._db);

  Future<List<DebtModel>> getAllByUserId(String userId) async {
    try {
      final rows = await (_db.select(_db.debts)
            ..where((d) => d.userId.equals(userId))
            ..where((d) => d.deletedAt.isNull())
            ..orderBy([(d) => OrderingTerm.desc(d.createdAt)]))
          .get();
      return rows.map(DebtModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get debts: $e');
    }
  }

  Future<DebtModel> insert(DebtModel model) async {
    try {
      await _db.into(_db.debts).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create debt: $e');
    }
  }

  Future<DebtModel> update(DebtEntity debt) async {
    try {
      final model = DebtModel(
        id: debt.id,
        userId: debt.userId,
        type: debt.type,
        personName: debt.personName,
        amount: debt.amount,
        paidAmount: debt.paidAmount,
        currencyCode: debt.currencyCode,
        deadline: debt.deadline,
        note: debt.note,
        status: debt.status,
        createdAt: debt.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: debt.deletedAt,
        syncStatus: 'pending',
      );
      await (_db.update(_db.debts)..where((d) => d.id.equals(debt.id)))
          .write(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update debt: $e');
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await (_db.update(_db.debts)..where((d) => d.id.equals(id))).write(
        DebtsCompanion(
          deletedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to delete debt: $e');
    }
  }

  Future<DebtModel> addPayment({
    required String debtId,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      final payment = DebtPaymentModel.create(
        debtId: debtId,
        amount: amount,
        date: date,
        note: note,
      );
      await _db.transaction(() async {
        await _db.into(_db.debtPayments).insert(payment.toCompanion());
        final row = await (_db.select(_db.debts)
              ..where((d) => d.id.equals(debtId)))
            .getSingle();
        final newPaid = row.paidAmount + amount;
        final newStatus = newPaid >= row.amount
            ? DebtStatus.settled.value
            : DebtStatus.partiallyPaid.value;
        await (_db.update(_db.debts)..where((d) => d.id.equals(debtId)))
            .write(DebtsCompanion(
          paidAmount: Value(newPaid),
          status: Value(newStatus),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ));
      });
      final updated = await (_db.select(_db.debts)
            ..where((d) => d.id.equals(debtId)))
          .getSingle();
      return DebtModel.fromDrift(updated);
    } catch (e) {
      throw LocalDatabaseException('Failed to add payment: $e');
    }
  }

  Future<List<DebtPaymentModel>> getPayments(String debtId) async {
    try {
      final rows = await (_db.select(_db.debtPayments)
            ..where((p) => p.debtId.equals(debtId))
            ..orderBy([(p) => OrderingTerm.desc(p.date)]))
          .get();
      return rows.map(DebtPaymentModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get payments: $e');
    }
  }
}
