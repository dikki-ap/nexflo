import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/enums/goal_status.dart';
import '../../models/goal_model.dart';
import '../../../domain/entities/goal_entity.dart';

class GoalLocalDataSource {
  final AppDatabase _db;
  GoalLocalDataSource(this._db);

  Future<List<GoalModel>> getAllByUserId(String userId) async {
    try {
      final rows = await (_db.select(_db.goals)
            ..where((g) => g.userId.equals(userId))
            ..where((g) => g.deletedAt.isNull())
            ..orderBy([(g) => OrderingTerm.asc(g.createdAt)]))
          .get();
      return rows.map(GoalModel.fromDrift).toList();
    } catch (e) {
      throw LocalDatabaseException('Failed to get goals: $e');
    }
  }

  Future<GoalModel> insert(GoalModel model) async {
    try {
      await _db.into(_db.goals).insert(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to create goal: $e');
    }
  }

  Future<GoalModel> update(GoalEntity goal) async {
    try {
      final model = GoalModel(
        id: goal.id,
        userId: goal.userId,
        walletId: goal.walletId,
        name: goal.name,
        iconName: goal.iconName,
        colorHex: goal.colorHex,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        deadline: goal.deadline,
        status: goal.status,
        note: goal.note,
        createdAt: goal.createdAt,
        updatedAt: DateTime.now(),
        deletedAt: goal.deletedAt,
        syncStatus: 'pending',
      );
      await (_db.update(_db.goals)..where((g) => g.id.equals(goal.id)))
          .write(model.toCompanion());
      return model;
    } catch (e) {
      throw LocalDatabaseException('Failed to update goal: $e');
    }
  }

  Future<void> softDelete(String id) async {
    try {
      await (_db.update(_db.goals)..where((g) => g.id.equals(id))).write(
        GoalsCompanion(
          deletedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
    } catch (e) {
      throw LocalDatabaseException('Failed to delete goal: $e');
    }
  }

  Future<GoalModel> updateAmount(String goalId, double newAmount) async {
    try {
      final newStatus = newAmount >= (await _getTargetAmount(goalId))
          ? GoalStatus.completed.value
          : GoalStatus.active.value;
      await (_db.update(_db.goals)..where((g) => g.id.equals(goalId))).write(
        GoalsCompanion(
          currentAmount: Value(newAmount),
          status: Value(newStatus),
          updatedAt: Value(DateTime.now()),
          syncStatus: const Value('pending'),
        ),
      );
      final row = await (_db.select(_db.goals)
            ..where((g) => g.id.equals(goalId)))
          .getSingle();
      return GoalModel.fromDrift(row);
    } catch (e) {
      throw LocalDatabaseException('Failed to update goal amount: $e');
    }
  }

  Future<double> _getTargetAmount(String goalId) async {
    final row = await (_db.select(_db.goals)
          ..where((g) => g.id.equals(goalId)))
        .getSingle();
    return row.targetAmount;
  }
}
