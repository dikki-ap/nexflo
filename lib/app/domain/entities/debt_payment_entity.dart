import 'package:equatable/equatable.dart';

class DebtPaymentEntity extends Equatable {
  final String id;
  final String debtId;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final String syncStatus;

  const DebtPaymentEntity({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
    required this.syncStatus,
  });

  @override
  List<Object?> get props => [id, debtId, amount, date];
}
