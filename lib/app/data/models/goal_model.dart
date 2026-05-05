import 'package:drift/drift.dart' show Value;
import '../../core/enums/goal_status.dart';
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/goal_entity.dart';
import '../database/app_database.dart';

class GoalModel extends GoalEntity {
  const GoalModel({
    required super.id,
    required super.userId,
    super.walletId,
    required super.name,
    required super.iconName,
    required super.colorHex,
    required super.targetAmount,
    required super.currentAmount,
    super.deadline,
    required super.status,
    super.note,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });

  factory GoalModel.fromDrift(Goal g) => GoalModel(
        id: g.id,
        userId: g.userId,
        walletId: g.walletId,
        name: g.name,
        iconName: g.iconName,
        colorHex: g.colorHex,
        targetAmount: g.targetAmount,
        currentAmount: g.currentAmount,
        deadline: g.deadline,
        status: GoalStatus.fromValue(g.status),
        note: g.note,
        createdAt: g.createdAt,
        updatedAt: g.updatedAt,
        deletedAt: g.deletedAt,
        syncStatus: g.syncStatus,
      );

  static GoalModel create({
    required String userId,
    String? walletId,
    required String name,
    required String iconName,
    required String colorHex,
    required double targetAmount,
    DateTime? deadline,
    String? note,
  }) {
    final now = DateTime.now();
    return GoalModel(
      id: UuidHelper.generate(),
      userId: userId,
      walletId: walletId,
      name: name,
      iconName: iconName,
      colorHex: colorHex,
      targetAmount: targetAmount,
      currentAmount: 0,
      deadline: deadline,
      status: GoalStatus.active,
      note: note,
      createdAt: now,
      updatedAt: now,
      syncStatus: 'pending',
    );
  }

  GoalsCompanion toCompanion() => GoalsCompanion(
        id: Value(id),
        userId: Value(userId),
        walletId: Value(walletId),
        name: Value(name),
        iconName: Value(iconName),
        colorHex: Value(colorHex),
        targetAmount: Value(targetAmount),
        currentAmount: Value(currentAmount),
        deadline: Value(deadline),
        status: Value(status.value),
        note: Value(note),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
        syncStatus: Value(syncStatus),
      );

  GoalModel copyWith({
    String? walletId,
    String? name,
    String? iconName,
    String? colorHex,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    GoalStatus? status,
    String? note,
    DateTime? deletedAt,
  }) =>
      GoalModel(
        id: id,
        userId: userId,
        walletId: walletId ?? this.walletId,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        colorHex: colorHex ?? this.colorHex,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        deadline: deadline ?? this.deadline,
        status: status ?? this.status,
        note: note ?? this.note,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        deletedAt: deletedAt ?? this.deletedAt,
        syncStatus: 'pending',
      );
}
