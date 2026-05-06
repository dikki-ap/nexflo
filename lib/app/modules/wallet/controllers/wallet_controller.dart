import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/wallet_type.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../data/datasources/local/wallet_local_ds.dart';
import '../../../data/datasources/local/transaction_local_ds.dart';
import '../../../data/repositories/wallet_repository_impl.dart';
import '../../../data/repositories/transaction_repository_impl.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../domain/usecases/wallet/get_all_wallets_usecase.dart';
import '../../../domain/usecases/wallet/create_wallet_usecase.dart';
import '../../../domain/usecases/wallet/update_wallet_usecase.dart';
import '../../../domain/usecases/wallet/delete_wallet_usecase.dart';
import '../../../domain/usecases/wallet/reorder_wallets_usecase.dart';
import '../../../domain/usecases/wallet/adjust_wallet_balance_usecase.dart';
import '../../../domain/usecases/transaction/create_transaction_usecase.dart';
import '../../../services/auth_service.dart';

class WalletController extends GetxController {
  final wallets = <WalletEntity>[].obs;
  final isLoading = false.obs;

  // Form fields
  final nameCtrl = TextEditingController();
  final balanceCtrl = TextEditingController();
  final creditLimitCtrl = TextEditingController();
  final selectedType = WalletType.cash.obs;
  final selectedColor = AppColors.teal.obs;
  final selectedIcon = 'wallet'.obs;
  final selectedCurrency = 'IDR'.obs;
  final isExcludeTotal = false.obs;

  late final GetAllWalletsUseCase _getAll;
  late final CreateWalletUseCase _create;
  late final UpdateWalletUseCase _update;
  late final DeleteWalletUseCase _delete;
  late final ReorderWalletsUseCase _reorder;
  late final AdjustWalletBalanceUseCase _adjustBalance;
  late final CreateTransactionUseCase _createTx;

  String get _userId => Get.find<AuthService>().currentUser?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();
    final walletDs = WalletLocalDataSource(db);
    final walletRepo = WalletRepositoryImpl(walletDs);
    final txDs = TransactionLocalDataSource(db);
    final txRepo = TransactionRepositoryImpl(txDs);

    _getAll = GetAllWalletsUseCase(walletRepo);
    _create = CreateWalletUseCase(walletRepo);
    _update = UpdateWalletUseCase(walletRepo);
    _delete = DeleteWalletUseCase(walletRepo);
    _reorder = ReorderWalletsUseCase(walletRepo);
    _adjustBalance = AdjustWalletBalanceUseCase(walletRepo);
    _createTx = CreateTransactionUseCase(txRepo);

    loadWallets();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    balanceCtrl.dispose();
    creditLimitCtrl.dispose();
    super.onClose();
  }

  Future<void> loadWallets() async {
    isLoading.value = true;
    final result = await _getAll(GetAllWalletsParams(_userId));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (list) => wallets.value = list,
    );
    isLoading.value = false;
  }

  void prepareForm([WalletEntity? existing]) {
    if (existing != null) {
      nameCtrl.text = existing.name;
      balanceCtrl.text = existing.balance.toStringAsFixed(0);
      creditLimitCtrl.text = existing.creditLimit?.toStringAsFixed(0) ?? '';
      selectedType.value = existing.type;
      selectedColor.value = _colorFromHex(existing.colorHex);
      selectedIcon.value = existing.iconName;
      selectedCurrency.value = existing.currencyCode;
      isExcludeTotal.value = existing.isExcludeTotal;
    } else {
      nameCtrl.clear();
      balanceCtrl.text = '0';
      creditLimitCtrl.clear();
      selectedType.value = WalletType.cash;
      selectedColor.value = AppColors.teal;
      selectedIcon.value = 'wallet';
      selectedCurrency.value = 'IDR';
      isExcludeTotal.value = false;
    }
  }

  Future<void> save([WalletEntity? existing]) async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Validation', 'Wallet name cannot be empty');
      return;
    }
    isLoading.value = true;

    if (existing == null) {
      final result = await _create(CreateWalletParams(
        userId: _userId,
        name: name,
        type: selectedType.value.value,
        colorHex: _hexFromColor(selectedColor.value),
        iconName: selectedIcon.value,
        currencyCode: selectedCurrency.value,
        initialBalance: double.tryParse(balanceCtrl.text) ?? 0,
        creditLimit: creditLimitCtrl.text.isNotEmpty
            ? double.tryParse(creditLimitCtrl.text)
            : null,
        isExcludeTotal: isExcludeTotal.value,
      ));
      result.fold(
        (f) => Get.snackbar('Error', f.message),
        (_) {},
      );
    } else {
      // Build updated entity
      final updated = WalletEntityHelper.copyWith(
        existing,
        name: name,
        colorHex: _hexFromColor(selectedColor.value),
        iconName: selectedIcon.value,
        isExcludeTotal: isExcludeTotal.value,
      );
      final result = await _update(updated);
      result.fold(
        (f) => Get.snackbar('Error', f.message),
        (_) {},
      );
    }

    isLoading.value = false;
    await loadWallets();
    Get.back();
  }

  Future<void> deleteWallet(String id) async {
    final result = await _delete(DeleteWalletParams(id));
    result.fold(
      (f) => Get.snackbar('Error', f.message),
      (_) => wallets.removeWhere((w) => w.id == id),
    );
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = wallets.toList();
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    wallets.value = list;
    await _reorder(ReorderWalletsParams(
      _userId,
      list.map((w) => w.id).toList(),
    ));
  }

  Future<void> adjustBalance({
    required WalletEntity wallet,
    required double newBalance,
    required bool withRecord,
  }) async {
    final result = await _adjustBalance(AdjustBalanceParams(
      walletId: wallet.id,
      newBalance: newBalance,
    ));
    result.fold((f) => Get.snackbar('Error', f.message), (_) {});

    if (withRecord) {
      final diff = newBalance - wallet.balance;
      if (diff != 0) {
        await _createTx(CreateTransactionParams(
          userId: _userId,
          walletId: wallet.id,
          type: diff > 0 ? 'income' : 'expense',
          amount: diff.abs(),
          date: DateTime.now(),
          note: 'Balance adjustment',
        ));
      }
    }
    await loadWallets();
    Get.back();
  }

  String _hexFromColor(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  Color _colorFromHex(String hex) {
    final s = hex.replaceAll('#', '');
    return Color(int.parse('FF$s', radix: 16));
  }

  double get totalNetWorth => wallets
      .where((w) => !w.isExcludeTotal && !w.isArchived && w.deletedAt == null)
      .fold(0.0, (sum, w) => sum + w.balance);
}

class WalletEntityHelper {
  static WalletEntity copyWith(
    WalletEntity w, {
    String? name,
    String? colorHex,
    String? iconName,
    bool? isExcludeTotal,
    bool? isArchived,
    double? balance,
  }) {
    return _WalletCopy(
      id: w.id,
      userId: w.userId,
      name: name ?? w.name,
      type: w.type,
      colorHex: colorHex ?? w.colorHex,
      iconName: iconName ?? w.iconName,
      balance: balance ?? w.balance,
      currencyCode: w.currencyCode,
      creditLimit: w.creditLimit,
      isExcludeTotal: isExcludeTotal ?? w.isExcludeTotal,
      sortOrder: w.sortOrder,
      isArchived: isArchived ?? w.isArchived,
      createdAt: w.createdAt,
      updatedAt: DateTime.now(),
      deletedAt: w.deletedAt,
      syncStatus: 'pending',
    );
  }
}

class _WalletCopy extends WalletEntity {
  const _WalletCopy({
    required super.id,
    required super.userId,
    required super.name,
    required super.type,
    required super.colorHex,
    required super.iconName,
    required super.balance,
    required super.currencyCode,
    super.creditLimit,
    required super.isExcludeTotal,
    required super.sortOrder,
    required super.isArchived,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
    required super.syncStatus,
  });
}
