import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/budget_period.dart';
import '../../../data/datasources/local/budget_local_ds.dart';
import '../../../data/datasources/local/category_local_ds.dart';
import '../../../data/datasources/local/wallet_local_ds.dart';
import '../../../data/repositories/budget_repository_impl.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../data/repositories/wallet_repository_impl.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../domain/usecases/budget/get_all_budgets_usecase.dart';
import '../../../domain/usecases/budget/create_budget_usecase.dart';
import '../../../domain/usecases/budget/update_budget_usecase.dart';
import '../../../domain/usecases/budget/delete_budget_usecase.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../domain/usecases/wallet/get_all_wallets_usecase.dart';
import '../../../services/auth_service.dart';

class BudgetController extends GetxController {
  final budgets = <BudgetEntity>[].obs;
  final budgetSpent = <String, double>{}.obs;
  final categories = <CategoryEntity>[].obs;
  final wallets = <WalletEntity>[].obs;
  final isLoading = false.obs;

  // Form state
  final nameCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final selectedPeriod = BudgetPeriod.monthly.obs;
  final selectedCategoryId = Rxn<String>();
  final selectedWalletId = Rxn<String>();
  final isAllCategories = true.obs;
  final rollover = false.obs;
  final alertAtPercent = 80.obs;

  late final GetAllBudgetsUseCase _getAll;
  late final CreateBudgetUseCase _create;
  late final UpdateBudgetUseCase _update;
  late final DeleteBudgetUseCase _delete;
  late final GetCategoriesUseCase _getCategories;
  late final GetAllWalletsUseCase _getWallets;
  late final BudgetLocalDataSource _budgetDs;

  String get _userId => Get.find<AuthService>().currentUser!.id;

  final rolloverAmounts = <String, double>{}.obs;
  final alertBudgets = <BudgetEntity>[].obs;

  double spentFor(BudgetEntity b) => budgetSpent[b.id] ?? 0;
  double effectiveLimitFor(BudgetEntity b) =>
      b.amount + (rolloverAmounts[b.id] ?? 0);
  double progressFor(BudgetEntity b) {
    final limit = effectiveLimitFor(b);
    return limit > 0 ? spentFor(b) / limit : 0;
  }

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();
    _budgetDs = BudgetLocalDataSource(db);
    _getAll = GetAllBudgetsUseCase(BudgetRepositoryImpl(_budgetDs));
    _create = CreateBudgetUseCase(BudgetRepositoryImpl(_budgetDs));
    _update = UpdateBudgetUseCase(BudgetRepositoryImpl(_budgetDs));
    _delete = DeleteBudgetUseCase(BudgetRepositoryImpl(_budgetDs));
    _getCategories =
        GetCategoriesUseCase(CategoryRepositoryImpl(CategoryLocalDataSource(db)));
    _getWallets =
        GetAllWalletsUseCase(WalletRepositoryImpl(WalletLocalDataSource(db)));
    loadAll();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    amountCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    final uid = _userId;
    await Future.wait([
      _loadBudgetsWithSpent(uid),
      _getCategories(GetCategoriesParams(uid))
          .then((r) => r.fold((_) {}, (l) => categories.value = l)),
      _getWallets(GetAllWalletsParams(uid))
          .then((r) => r.fold((_) {}, (l) => wallets.value = l)),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadBudgetsWithSpent(String uid) async {
    final result = await _getAll(GetAllBudgetsParams(uid));
    if (result.isLeft()) return;
    final list = result.getOrElse(() => []);
    budgets.value = list;
    for (final b in list) {
      budgetSpent[b.id] = await _budgetDs.getSpentAmount(userId: uid, budget: b);
    }
    rolloverAmounts.clear();
    for (final b in list.where((b) => b.rollover)) {
      final prevSpent = await _budgetDs.getPreviousPeriodSpent(
        userId: uid,
        budget: b,
      );
      final carryOver = (b.amount - prevSpent).clamp(0.0, double.infinity);
      if (carryOver > 0) rolloverAmounts[b.id] = carryOver;
    }
    alertBudgets.value = list.where((b) {
      final limit = effectiveLimitFor(b);
      if (limit <= 0) return false;
      return spentFor(b) / limit * 100 >= b.alertAtPercent;
    }).toList();
  }

  void initForm([BudgetEntity? existing]) {
    if (existing != null) {
      nameCtrl.text = existing.name;
      amountCtrl.text = existing.amount.toStringAsFixed(0);
      selectedPeriod.value = existing.period;
      selectedCategoryId.value = existing.categoryId;
      selectedWalletId.value = existing.walletId;
      isAllCategories.value = existing.isAllCategories;
      rollover.value = existing.rollover;
      alertAtPercent.value = existing.alertAtPercent;
    } else {
      nameCtrl.clear();
      amountCtrl.clear();
      selectedPeriod.value = BudgetPeriod.monthly;
      selectedCategoryId.value = null;
      selectedWalletId.value = null;
      isAllCategories.value = true;
      rollover.value = false;
      alertAtPercent.value = 80;
    }
  }

  Future<void> saveBudget([BudgetEntity? existing]) async {
    final name = nameCtrl.text.trim();
    final amount = double.tryParse(amountCtrl.text) ?? 0;
    if (name.isEmpty || amount <= 0) {
      Get.snackbar('Error', 'Name and amount are required');
      return;
    }

    isLoading.value = true;
    if (existing == null) {
      final result = await _create(CreateBudgetParams(
        userId: _userId,
        name: name,
        amount: amount,
        period: selectedPeriod.value.value,
        categoryId: isAllCategories.value ? null : selectedCategoryId.value,
        walletId: selectedWalletId.value,
        isAllCategories: isAllCategories.value,
        rollover: rollover.value,
        alertAtPercent: alertAtPercent.value,
      ));
      result.fold((f) => Get.snackbar('Error', f.message), (_) {
        Get.back();
        loadAll();
      });
    } else {
      final updated = _BudgetCopy(
        id: existing.id,
        userId: existing.userId,
        name: name,
        amount: amount,
        period: selectedPeriod.value,
        categoryId: isAllCategories.value ? null : selectedCategoryId.value,
        walletId: selectedWalletId.value,
        isAllCategories: isAllCategories.value,
        rollover: rollover.value,
        alertAtPercent: alertAtPercent.value,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      final result = await _update(updated);
      result.fold((f) => Get.snackbar('Error', f.message), (_) {
        Get.back();
        loadAll();
      });
    }
    isLoading.value = false;
  }

  Future<void> deleteBudget(String id) async {
    final result = await _delete(DeleteBudgetParams(id));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) => loadAll(),
    );
  }
}

class _BudgetCopy extends BudgetEntity {
  const _BudgetCopy({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.period,
    super.categoryId,
    super.walletId,
    required super.isAllCategories,
    required super.rollover,
    required super.alertAtPercent,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });
}
