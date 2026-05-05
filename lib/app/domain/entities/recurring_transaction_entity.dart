import 'package:equatable/equatable.dart';
import '../../core/enums/transaction_type.dart';
import '../../core/enums/recurrence_type.dart';

class RecurringTransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String walletId;
  final String? toWalletId;
  final String? categoryId;
  final TransactionType type;
  final double amount;
  final String? note;
  final RecurrenceType recurrenceType;
  final int recurrenceInterval;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final DateTime? lastProcessedDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;

  const RecurringTransactionEntity({
    required this.id,
    required this.userId,
    required this.walletId,
    this.toWalletId,
    this.categoryId,
    required this.type,
    required this.amount,
    this.note,
    required this.recurrenceType,
    required this.recurrenceInterval,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.lastProcessedDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });

  String get recurrenceLabel => recurrenceInterval == 1
      ? recurrenceType.label
      : 'Every $recurrenceInterval ${recurrenceType.label.toLowerCase()}s';

  @override
  List<Object?> get props => [id, walletId, type, amount, recurrenceType];
}
