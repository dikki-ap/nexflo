import 'package:drift/drift.dart' show Value;
import '../../core/enums/debt_type.dart';
import '../../core/enums/debt_status.dart';
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/debt_entity.dart';
import '../database/app_database.dart';

class DebtModel extends DebtEntity {
  const DebtModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.personName,
    required super.amount,
    required super.paidAmount,
    required super.currencyCode,
    super.deadline,
    super.note,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });

  factory DebtModel.fromDrift(Debt d) => DebtModel(
        id: d.id,
        userId: d.userId,
        type: DebtType.fromValue(d.type),
        personName: d.personName,
        amount: d.amount,
        paidAmount: d.paidAmount,
        currencyCode: d.currencyCode,
        deadline: d.deadline,
        note: d.note,
        status: DebtStatus.fromValue(d.status),
        createdAt: d.createdAt,
        updatedAt: d.updatedAt,
        deletedAt: d.deletedAt,
        syncStatus: d.syncStatus,
      );

  static DebtModel create({
    required String userId,
    required String type,
    required String personName,
    required double amount,
    required String currencyCode,
    DateTime? deadline,
    String? note,
  }) {
    final now = DateTime.now();
    return DebtModel(
      id: UuidHelper.generate(),
      userId: userId,
      type: DebtType.fromValue(type),
      personName: personName,
      amount: amount,
      paidAmount: 0,
      currencyCode: currencyCode,
      deadline: deadline,
      note: note,
      status: DebtStatus.active,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
  }

  DebtsCompanion toCompanion() => DebtsCompanion(
        id: Value(id),
        userId: Value(userId),
        type: Value(type.value),
        personName: Value(personName),
        amount: Value(amount),
        paidAmount: Value(paidAmount),
        currencyCode: Value(currencyCode),
        deadline: Value(deadline),
        note: Value(note),
        status: Value(status.value),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
        syncStatus: Value(syncStatus),
      );

  DebtModel copyWith({
    String? personName,
    double? amount,
    double? paidAmount,
    String? currencyCode,
    DateTime? deadline,
    String? note,
    DebtStatus? status,
    DateTime? deletedAt,
  }) =>
      DebtModel(
        id: id,
        userId: userId,
        type: type,
        personName: personName ?? this.personName,
        amount: amount ?? this.amount,
        paidAmount: paidAmount ?? this.paidAmount,
        currencyCode: currencyCode ?? this.currencyCode,
        deadline: deadline ?? this.deadline,
        note: note ?? this.note,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        deletedAt: deletedAt ?? this.deletedAt,
        syncStatus: 'pending',
      );
}
