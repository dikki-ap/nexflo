import 'package:equatable/equatable.dart';
import '../../core/enums/debt_type.dart';
import '../../core/enums/debt_status.dart';

class DebtEntity extends Equatable {
  final String id;
  final String userId;
  final DebtType type;
  final String personName;
  final double amount;
  final double paidAmount;
  final String currencyCode;
  final DateTime? deadline;
  final String? note;
  final DebtStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;

  const DebtEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.personName,
    required this.amount,
    required this.paidAmount,
    required this.currencyCode,
    this.deadline,
    this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });

  double get remaining => amount - paidAmount;

  bool get isOverdue =>
      deadline != null &&
      deadline!.isBefore(DateTime.now()) &&
      status != DebtStatus.settled;

  @override
  List<Object?> get props => [id, personName, amount, status];
}
