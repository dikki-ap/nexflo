import 'package:equatable/equatable.dart';
import '../../core/enums/transaction_type.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String walletId;
  final String? toWalletId;
  final String? categoryId;
  final String? subcategoryId;
  final TransactionType type;
  final double amount;
  final double? originalAmount;
  final String? originalCurrency;
  final double? exchangeRate;
  final String? note;
  final DateTime date;
  final String? receiptImagePath;
  final bool isRecurring;
  final String? recurringId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
  final int version;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.walletId,
    this.toWalletId,
    this.categoryId,
    this.subcategoryId,
    required this.type,
    required this.amount,
    this.originalAmount,
    this.originalCurrency,
    this.exchangeRate,
    this.note,
    required this.date,
    this.receiptImagePath,
    required this.isRecurring,
    this.recurringId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.version,
  });

  @override
  List<Object?> get props => [id, walletId, type, amount, date];
}
