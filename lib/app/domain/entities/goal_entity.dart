import 'package:equatable/equatable.dart';
import '../../core/enums/goal_status.dart';

class GoalEntity extends Equatable {
  final String id;
  final String userId;
  final String? walletId;
  final String name;
  final String iconName;
  final String colorHex;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final GoalStatus status;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;

  const GoalEntity({
    required this.id,
    required this.userId,
    this.walletId,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
  });

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0;

  int? get daysRemaining => deadline == null
      ? null
      : deadline!.difference(DateTime.now()).inDays;

  @override
  List<Object?> get props => [id, name, targetAmount, currentAmount];
}
