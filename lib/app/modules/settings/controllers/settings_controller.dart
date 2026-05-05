import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/theme_color.dart';
import '../../../data/datasources/local/currency_local_ds.dart';
import '../../../data/datasources/local/settings_local_ds.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/settings_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/currency_service.dart';
import '../../../services/sync_service.dart';

class SettingsController extends GetxController {
  late final SettingsLocalDataSource _settingsDs;
  late final CurrencyLocalDataSource _currencyDs;

  final settings = Rxn<SettingsModel>();
  final isLoading = false.obs;
  final currencies = <Currency>[].obs;
  final manualRateFrom = ''.obs;
  final manualRateTo = ''.obs;
  final manualRateValue = 0.0.obs;

  AuthService get _auth => Get.find<AuthService>();
  SyncService get _sync => Get.find<SyncService>();
  CurrencyService get _currencyService => Get.find<CurrencyService>();

  String? get userId => _auth.currentUser?.id;
  String? get userEmail => _auth.currentUser?.email;
  String? get userName => _auth.currentUser?.name;
  String? get userPhotoUrl => _auth.currentUser?.photoUrl;

  bool get isSyncing => _sync.isSyncing;
  SyncState get syncState => _sync.syncState;

  @override
  void onInit() {
    super.onInit();
    _settingsDs = SettingsLocalDataSource(Get.find<AppDatabase>());
    _currencyDs = CurrencyLocalDataSource(Get.find<AppDatabase>());
    loadSettings();
    loadCurrencies();
  }

  Future<void> loadSettings() async {
    if (userId == null) return;
    isLoading.value = true;
    try {
      settings.value = await _settingsDs.getByUserId(userId!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCurrencies() async {
    currencies.assignAll(await _currencyDs.getAll());
  }

  Future<void> updateBaseCurrency(String code) async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(baseCurrencyCode: code);
    await _settingsDs.update(updated);
    _currencyService.setBaseCurrency(code);
    settings.value = updated;
  }

  Future<void> updateCutoffDate(int date) async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(cutoffDate: date);
    await _settingsDs.update(updated);
    settings.value = updated;
  }

  Future<void> updateThemeMode(String mode) async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(themeMode: mode);
    await _settingsDs.update(updated);
    settings.value = updated;

    final themeCtrl = Get.find<dynamic>(tag: 'AppThemeController');
    themeCtrl.setThemeMode(_themeModeFrom(mode));
  }

  Future<void> updateThemeColor(ThemeColor color) async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(themeColor: color);
    await _settingsDs.update(updated);
    settings.value = updated;
  }

  Future<void> toggleSyncEnabled(bool value) async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(syncEnabled: value);
    await _settingsDs.update(updated);
    settings.value = updated;
  }

  Future<void> toggleBudgetAlert(bool value) async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(notificationBudgetAlert: value);
    await _settingsDs.update(updated);
    settings.value = updated;
  }

  Future<void> toggleRecurringReminder(bool value) async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(notificationRecurringReminder: value);
    await _settingsDs.update(updated);
    settings.value = updated;
  }

  Future<void> toggleDebtReminder(bool value) async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(notificationDebtReminder: value);
    await _settingsDs.update(updated);
    settings.value = updated;
  }

  Future<void> triggerSync() async {
    await _sync.sync();
    await loadSettings(); // Refresh lastSyncAt
  }

  Future<void> disconnectSheets() async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(sheetsSpreadsheetId: '');
    await _settingsDs.update(updated);
    settings.value = updated;
    Get.snackbar('Disconnected', 'Google Sheets sync disconnected',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> saveManualRate() async {
    if (manualRateFrom.value.isEmpty ||
        manualRateTo.value.isEmpty ||
        manualRateValue.value <= 0) {
      Get.snackbar('Error', 'Fill all fields with valid values',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await _currencyService.setManualRate(
      fromCurrency: manualRateFrom.value,
      toCurrency: manualRateTo.value,
      rate: manualRateValue.value,
    );
    Get.snackbar('Saved', 'Exchange rate saved',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> refreshRates() async {
    await _currencyService.refreshRates();
    Get.snackbar('Updated', 'Exchange rates refreshed',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> signOut() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      _auth.clearUser();
      Get.offAllNamed('/login');
    }
  }

  ThemeMode _themeModeFrom(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
