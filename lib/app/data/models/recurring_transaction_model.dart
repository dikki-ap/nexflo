import 'package:drift/drift.dart' show Value;
import '../../core/enums/transaction_type.dart';
import '../../core/enums/recurrence_type.dart';
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/recurring_transaction_entity.dart';
import '../database/app_database.dart';

class RecurringTransactionModel extends RecurringTransactionEntity {
  const RecurringTransactionModel({
    required super.id,
    required super.userId,
    required super.walletId,
    super.toWalletId,
    super.categoryId,
    required super.type,
    required super.amount,
    super.note,
    required super.recurrenceType,
    required super.recurrenceInterval,
    required super.startDate,
    super.endDate,
    required super.nextDueDate,
    super.lastProcessedDate,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });

  factory RecurringTransactionModel.fromDrift(RecurringTransaction r) =>
      RecurringTransactionModel(
        id: r.id,
        userId: r.userId,
        walletId: r.walletId,
        toWalletId: r.toWalletId,
        categoryId: r.categoryId,
        type: TransactionType.fromValue(r.type),
        amount: r.amount,
        note: r.note,
        recurrenceType: RecurrenceType.fromValue(r.recurrenceType),
        recurrenceInterval: r.recurrenceInterval,
        startDate: r.startDate,
        endDate: r.endDate,
        nextDueDate: r.nextDueDate,
        lastProcessedDate: r.lastProcessedDate,
        isActive: r.isActive,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
        deletedAt: r.deletedAt,
        syncStatus: r.syncStatus,
      );

  static RecurringTransactionModel create({
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
  }) {
    final now = DateTime.now();
    return RecurringTransactionModel(
      id: UuidHelper.generate(),
      userId: userId,
      walletId: walletId,
      toWalletId: toWalletId,
      categoryId: categoryId,
      type: TransactionType.fromValue(type),
      amount: amount,
      note: note,
      recurrenceType: RecurrenceType.fromValue(recurrenceType),
      recurrenceInterval: recurrenceInterval,
      startDate: startDate,
      endDate: endDate,
      nextDueDate: startDate,
      isActive: true,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
  }

  RecurringTransactionsCompanion toCompanion() => RecurringTransactionsCompanion(
        id: Value(id),
        userId: Value(userId),
        walletId: Value(walletId),
        toWalletId: Value(toWalletId),
        categoryId: Value(categoryId),
        type: Value(type.value),
        amount: Value(amount),
        note: Value(note),
        recurrenceType: Value(recurrenceType.value),
        recurrenceInterval: Value(recurrenceInterval),
        startDate: Value(startDate),
        endDate: Value(endDate),
        nextDueDate: Value(nextDueDate),
        lastProcessedDate: Value(lastProcessedDate),
        isActive: Value(isActive),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
        syncStatus: Value(syncStatus),
      );
}
