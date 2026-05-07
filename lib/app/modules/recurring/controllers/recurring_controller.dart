import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../core/enums/recurrence_type.dart';
import '../../../data/datasources/local/recurring_local_ds.dart';
import '../../../data/datasources/local/wallet_local_ds.dart';
import '../../../data/datasources/local/category_local_ds.dart';
import '../../../data/repositories/recurring_repository_impl.dart';
import '../../../data/repositories/wallet_repository_impl.dart';
import '../../../data/repositories/category_repository_impl.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/recurring_transaction_entity.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/recurring/get_recurring_usecase.dart';
import '../../../domain/usecases/recurring/create_recurring_usecase.dart';
import '../../../domain/usecases/recurring/update_recurring_usecase.dart';
import '../../../domain/usecases/recurring/delete_recurring_usecase.dart';
import '../../../domain/usecases/wallet/get_all_wallets_usecase.dart';
import '../../../domain/usecases/category/get_categories_usecase.dart';
import '../../../services/auth_service.dart';

class RecurringPreset {
  final String label;
  final RecurrenceType type;
  final int interval;
  const RecurringPreset(this.label, this.type, this.interval);
}

class RecurringController extends GetxController {
  static const presets = [
    RecurringPreset('Daily', RecurrenceType.daily, 1),
    RecurringPreset('Weekly', RecurrenceType.weekly, 1),
    RecurringPreset('Every 2 Weeks', RecurrenceType.weekly, 2),
    RecurringPreset('Monthly', RecurrenceType.monthly, 1),
    RecurringPreset('Quarterly', RecurrenceType.monthly, 3),
    RecurringPreset('Yearly', RecurrenceType.yearly, 1),
  ];

  final recurringList = <RecurringTransactionEntity>[].obs;
  final wallets = <WalletEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final isLoading = false.obs;

  // Form state
  final amountCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  final selectedType = TransactionType.expense.obs;
  final selectedWalletId = Rxn<String>();
  final selectedToWalletId = Rxn<String>();
  final selectedCategoryId = Rxn<String>();
  final selectedPresetIndex = 3.obs; // default: Monthly
  final startDate = DateTime.now().obs;
  final endDate = Rxn<DateTime>();
  final chargeHour = 9.obs;
  final chargeMinute = 0.obs;

  RecurrenceType get selectedRecurrenceType =>
      presets[selectedPresetIndex.value].type;
  int get selectedInterval => presets[selectedPresetIndex.value].interval;

  void selectPreset(int index) => selectedPresetIndex.value = index;

  int _presetIndexFor(RecurrenceType type, int interval) {
    for (var i = 0; i < presets.length; i++) {
      if (presets[i].type == type && presets[i].interval == interval) return i;
    }
    return 3; // fallback: Monthly
  }

  late final GetRecurringUseCase _getAll;
  late final CreateRecurringUseCase _create;
  late final UpdateRecurringUseCase _update;
  late final DeleteRecurringUseCase _delete;
  late final GetAllWalletsUseCase _getWallets;
  late final GetCategoriesUseCase _getCategories;
  late final RecurringLocalDataSource _recurringDs;

  String get _userId => Get.find<AuthService>().currentUser?.id ?? '';

  List<RecurringTransactionEntity> get activeList =>
      recurringList.where((r) => r.isActive).toList();
  List<RecurringTransactionEntity> get inactiveList =>
      recurringList.where((r) => !r.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();
    _recurringDs = RecurringLocalDataSource(db);
    final repo = RecurringRepositoryImpl(_recurringDs);
    _getAll = GetRecurringUseCase(repo);
    _create = CreateRecurringUseCase(repo);
    _update = UpdateRecurringUseCase(repo);
    _delete = DeleteRecurringUseCase(repo);
    _getWallets =
        GetAllWalletsUseCase(WalletRepositoryImpl(WalletLocalDataSource(db)));
    _getCategories = GetCategoriesUseCase(
        CategoryRepositoryImpl(CategoryLocalDataSource(db)));
    _loadAll();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    noteCtrl.dispose();
    super.onClose();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    await Future.wait([
      _getAll(GetRecurringParams(_userId)).then(
          (r) => r.fold((_) {}, (list) => recurringList.value = list)),
      _getWallets(GetAllWalletsParams(_userId)).then((r) => r.fold((_) {}, (l) {
            wallets.value = l;
            if (l.isNotEmpty && selectedWalletId.value == null) {
              selectedWalletId.value = l.first.id;
            }
          })),
      _getCategories(GetCategoriesParams(_userId))
          .then((r) => r.fold((_) {}, (l) => categories.value = l)),
    ]);
    isLoading.value = false;
  }

  void initForm([RecurringTransactionEntity? existing]) {
    if (existing != null) {
      amountCtrl.text = existing.amount.toStringAsFixed(0);
      noteCtrl.text = existing.note ?? '';
      selectedType.value = existing.type;
      selectedWalletId.value = existing.walletId;
      selectedToWalletId.value = existing.toWalletId;
      selectedCategoryId.value = existing.categoryId;
      selectedPresetIndex.value =
          _presetIndexFor(existing.recurrenceType, existing.recurrenceInterval);
      startDate.value = existing.startDate;
      endDate.value = existing.endDate;
      chargeHour.value = existing.startDate.hour;
      chargeMinute.value = existing.startDate.minute;
    } else {
      amountCtrl.clear();
      noteCtrl.clear();
      selectedType.value = TransactionType.expense;
      selectedToWalletId.value = null;
      selectedCategoryId.value = null;
      selectedPresetIndex.value = 3; // Monthly
      startDate.value = DateTime.now();
      endDate.value = null;
      chargeHour.value = 9;
      chargeMinute.value = 0;
      if (wallets.isNotEmpty) selectedWalletId.value = wallets.first.id;
    }
  }

  Future<void> save([RecurringTransactionEntity? existing]) async {
    final amount = double.tryParse(amountCtrl.text) ?? 0;
    if (amount <= 0) {
      Get.snackbar('Error', 'Enter a valid amount');
      return;
    }
    if (selectedWalletId.value == null) {
      Get.snackbar('Error', 'Select a wallet');
      return;
    }

    final effectiveStart = DateTime(
      startDate.value.year,
      startDate.value.month,
      startDate.value.day,
      chargeHour.value,
      chargeMinute.value,
    );

    isLoading.value = true;
    if (existing == null) {
      final r = await _create(CreateRecurringParams(
        userId: _userId,
        walletId: selectedWalletId.value!,
        toWalletId: selectedType.value == TransactionType.transfer
            ? selectedToWalletId.value
            : null,
        categoryId: selectedCategoryId.value,
        type: selectedType.value.value,
        amount: amount,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        recurrenceType: selectedRecurrenceType.value,
        recurrenceInterval: selectedInterval,
        startDate: effectiveStart,
        endDate: endDate.value,
      ));
      r.fold(
        (f) => Get.snackbar('Error', f.message),
        (_) { Get.back(); _loadAll(); },
      );
    } else {
      final updated = _RecurringCopy(
        id: existing.id,
        userId: existing.userId,
        walletId: selectedWalletId.value!,
        toWalletId: selectedType.value == TransactionType.transfer
            ? selectedToWalletId.value
            : null,
        categoryId: selectedCategoryId.value,
        type: selectedType.value,
        amount: amount,
        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
        recurrenceType: selectedRecurrenceType,
        recurrenceInterval: selectedInterval,
        startDate: effectiveStart,
        endDate: endDate.value,
        nextDueDate: existing.nextDueDate,
        lastProcessedDate: existing.lastProcessedDate,
        isActive: existing.isActive,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
        syncStatus: 'pending',
      );
      final r = await _update(updated);
      r.fold((f) => Get.snackbar('Error', f.message), (_) {
        Get.back();
        _loadAll();
      });
    }
    isLoading.value = false;
  }

  Future<void> toggleActive(RecurringTransactionEntity r) async {
    await _recurringDs.toggleActive(r.id, !r.isActive);
    _loadAll();
  }

  Future<void> delete(String id) async {
    final result = await _delete(DeleteRecurringParams(id));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) => _loadAll(),
    );
  }

  WalletEntity? walletById(String? id) =>
      id == null ? null : wallets.firstWhereOrNull((w) => w.id == id);

  CategoryEntity? categoryById(String? id) =>
      id == null ? null : categories.firstWhereOrNull((c) => c.id == id);
}

class _RecurringCopy extends RecurringTransactionEntity {
  const _RecurringCopy({
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
}
