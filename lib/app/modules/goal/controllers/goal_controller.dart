import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/goal_status.dart';
import '../../../core/utils/color_helper.dart';
import '../../../data/datasources/local/goal_local_ds.dart';
import '../../../data/repositories/goal_repository_impl.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../../domain/usecases/goal/get_all_goals_usecase.dart';
import '../../../domain/usecases/goal/create_goal_usecase.dart';
import '../../../domain/usecases/goal/update_goal_usecase.dart';
import '../../../domain/usecases/goal/delete_goal_usecase.dart';
import '../../../domain/usecases/goal/allocate_to_goal_usecase.dart';
import '../../../services/auth_service.dart';

class GoalController extends GetxController {
  final goals = <GoalEntity>[].obs;
  final isLoading = false.obs;

  // Form state
  final nameCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final allocateCtrl = TextEditingController();
  final selectedIcon = 'savings'.obs;
  final selectedColor = AppColors.teal.obs;
  final selectedDeadline = Rxn<DateTime>();

  late final GetAllGoalsUseCase _getAll;
  late final CreateGoalUseCase _create;
  late final UpdateGoalUseCase _update;
  late final DeleteGoalUseCase _delete;
  late final AllocateToGoalUseCase _allocate;

  String get _userId => Get.find<AuthService>().currentUser!.id;

  List<GoalEntity> get activeGoals =>
      goals.where((g) => g.status == GoalStatus.active).toList();
  List<GoalEntity> get completedGoals =>
      goals.where((g) => g.status == GoalStatus.completed).toList();

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();
    final ds = GoalLocalDataSource(db);
    final repo = GoalRepositoryImpl(ds);
    _getAll = GetAllGoalsUseCase(repo);
    _create = CreateGoalUseCase(repo);
    _update = UpdateGoalUseCase(repo);
    _delete = DeleteGoalUseCase(repo);
    _allocate = AllocateToGoalUseCase(repo);
    loadGoals();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    targetCtrl.dispose();
    noteCtrl.dispose();
    allocateCtrl.dispose();
    super.onClose();
  }

  Future<void> loadGoals() async {
    isLoading.value = true;
    final result = await _getAll(GetAllGoalsParams(_userId));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (list) => goals.value = list,
    );
    isLoading.value = false;
  }

  void initForm([GoalEntity? existing]) {
    if (existing != null) {
      nameCtrl.text = existing.name;
      targetCtrl.text = existing.targetAmount.toStringAsFixed(0);
      noteCtrl.text = existing.note ?? '';
      selectedIcon.value = existing.iconName;
      selectedColor.value = ColorHelper.fromHex(existing.colorHex);
      selectedDeadline.value = existing.deadline;
    } else {
      nameCtrl.clear();
      targetCtrl.clear();
      noteCtrl.clear();
      selectedIcon.value = 'savings';
      selectedColor.value = AppColors.teal;
      selectedDeadline.value = null;
    }
  }

  Future<void> saveGoal([GoalEntity? existing]) async {
    final name = nameCtrl.text.trim();
    final target = double.tryParse(targetCtrl.text) ?? 0;
    if (name.isEmpty || target <= 0) {
      Get.snackbar('Error', 'Name and target amount are required');
      return;
    }
    final colorHex =
        '#${selectedColor.value.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    isLoading.value = true;
    if (existing == null) {
      final result = await _create(CreateGoalParams(
        userId: _userId,
        name: name,
        iconName: selectedIcon.value,
        colorHex: colorHex,
        targetAmount: target,
        deadline: selectedDeadline.value,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
      ));
      result.fold((f) => Get.snackbar('Error', f.message), (_) {
        Get.back();
        loadGoals();
      });
    } else {
      final updated = _GoalCopy(
        id: existing.id,
        userId: existing.userId,
        walletId: existing.walletId,
        name: name,
        iconName: selectedIcon.value,
        colorHex: colorHex,
        targetAmount: target,
        currentAmount: existing.currentAmount,
        deadline: selectedDeadline.value,
        status: existing.status,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      final result = await _update(updated);
      result.fold((f) => Get.snackbar('Error', f.message), (_) {
        Get.back();
        loadGoals();
      });
    }
    isLoading.value = false;
  }

  Future<void> allocate(GoalEntity goal) async {
    final added = double.tryParse(allocateCtrl.text) ?? 0;
    if (added <= 0) {
      Get.snackbar('Error', 'Enter a valid amount');
      return;
    }
    final newTotal =
        (goal.currentAmount + added).clamp(0.0, goal.targetAmount);
    final result =
        await _allocate(AllocateParams(goalId: goal.id, amount: newTotal));
    result.fold((f) => Get.snackbar('Error', f.message), (_) {
      allocateCtrl.clear();
      Get.back();
      loadGoals();
    });
  }

  Future<void> deleteGoal(String id) async {
    final result = await _delete(DeleteGoalParams(id));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) => loadGoals(),
    );
  }

  DateTime? projectedCompletion(GoalEntity g) {
    if (g.status == GoalStatus.completed) return null;
    if (g.targetAmount <= 0 || g.currentAmount <= 0) return null;
    final daysElapsed = DateTime.now().difference(g.createdAt).inDays;
    if (daysElapsed <= 0) return null;
    final dailyRate = g.currentAmount / daysElapsed;
    final remaining = g.targetAmount - g.currentAmount;
    if (remaining <= 0) return null;
    final daysNeeded = (remaining / dailyRate).ceil();
    return DateTime.now().add(Duration(days: daysNeeded));
  }

  String onTrackLabel(GoalEntity g) {
    if (g.deadline == null || g.targetAmount == 0) return '';
    final totalDays =
        g.deadline!.difference(g.createdAt).inDays.toDouble();
    if (totalDays <= 0) return '';
    final daysElapsed =
        DateTime.now().difference(g.createdAt).inDays.toDouble();
    final expectedProgress = daysElapsed / totalDays;
    return g.progress >= expectedProgress ? 'On Track' : 'Behind Schedule';
  }
}

class _GoalCopy extends GoalEntity {
  const _GoalCopy({
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
}
