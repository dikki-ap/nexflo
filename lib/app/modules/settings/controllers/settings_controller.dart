import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../config/theme/app_theme_controller.dart';
import '../../../core/enums/filter_period.dart';
import '../../../core/enums/theme_color.dart';
import '../../../data/datasources/local/currency_local_ds.dart';
import '../../../data/datasources/local/settings_local_ds.dart';
import '../../../data/datasources/local/transaction_local_ds.dart';
import '../../../data/datasources/local/wallet_local_ds.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/settings_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/biometric_service.dart';
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

    Get.find<AppThemeController>().setThemeMode(_themeModeFrom(mode));
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

  // ── Security ────────────────────────────────────────────

  bool get isBiometricAvailable => Get.find<BiometricService>().isAvailable;

  Future<void> toggleBiometric(bool value) async {
    if (settings.value == null) return;
    if (value && !isBiometricAvailable) {
      Get.snackbar('Not Available', 'Biometric authentication is not set up on this device',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final updated = settings.value!.copyWith(isBiometricEnabled: value);
    await _settingsDs.update(updated);
    settings.value = updated;
  }

  Future<void> setupPin(String pin) async {
    if (settings.value == null) return;
    if (pin.length < 4) {
      Get.snackbar('Error', 'PIN must be at least 4 digits',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final hash = sha256.convert(utf8.encode(pin)).toString();
    final updated = settings.value!.copyWith(
      isPinEnabled: true,
      pinHash: hash,
    );
    await _settingsDs.update(updated);
    settings.value = updated;
    Get.snackbar('Success', 'PIN set successfully',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> removePin() async {
    if (settings.value == null) return;
    final updated = settings.value!.copyWith(
      isPinEnabled: false,
      pinHash: '',
    );
    await _settingsDs.update(updated);
    settings.value = updated;
    Get.snackbar('PIN Removed', 'PIN lock has been disabled',
        snackPosition: SnackPosition.BOTTOM);
  }

  bool verifyPin(String pin) {
    final stored = settings.value?.pinHash;
    if (stored == null || stored.isEmpty) return false;
    return sha256.convert(utf8.encode(pin)).toString() == stored;
  }

  // ── Data Management ──────────────────────────────────────

  Future<void> exportPdf() async {
    if (userId == null) return;
    final db = Get.find<AppDatabase>();
    final txDs = TransactionLocalDataSource(db);
    final walletDs = WalletLocalDataSource(db);

    final transactions = await txDs.getByFilter(
      userId: userId!,
      period: FilterPeriod.allTime,
    );
    final wallets = await walletDs.getAllByUserId(userId!);

    final doc = pw.Document();
    final dateStr = DateFormat('dd MMM yyyy').format(DateTime.now());

    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (_) => [
        pw.Header(level: 0, child: pw.Text('NexFlo — Financial Summary')),
        pw.Paragraph(text: 'Generated: $dateStr'),
        pw.SizedBox(height: 12),
        pw.Header(level: 1, child: pw.Text('Wallets')),
        pw.Table.fromTextArray(
          headers: ['Name', 'Type', 'Currency', 'Balance'],
          data: wallets.map((w) => [
            w.name, w.type, w.currencyCode,
            w.balance.toStringAsFixed(2),
          ]).toList(),
        ),
        pw.SizedBox(height: 16),
        pw.Header(level: 1, child: pw.Text('Recent Transactions')),
        pw.Table.fromTextArray(
          headers: ['Date', 'Type', 'Amount', 'Note'],
          data: transactions.take(100).map((t) => [
            DateFormat('dd/MM/yy').format(t.date),
            t.type.name,
            t.amount.toStringAsFixed(2),
            t.note ?? '',
          ]).toList(),
        ),
      ],
    ));

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  Future<void> exportJson() async {
    if (userId == null) return;
    final db = Get.find<AppDatabase>();
    final txDs = TransactionLocalDataSource(db);
    final walletDs = WalletLocalDataSource(db);

    final transactions = await txDs.getByFilter(
      userId: userId!,
      period: FilterPeriod.allTime,
    );
    final wallets = await walletDs.getAllByUserId(userId!);

    final data = {
      'exported_at': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'wallets': wallets.map((w) => {
        'id': w.id,
        'name': w.name,
        'type': w.type,
        'balance': w.balance,
        'currency_code': w.currencyCode,
      }).toList(),
      'transactions': transactions.map((t) => {
        'id': t.id,
        'wallet_id': t.walletId,
        'type': t.type.name,
        'amount': t.amount,
        'date': t.date.toIso8601String(),
        'note': t.note,
        'category_id': t.categoryId,
      }).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    await Printing.sharePdf(bytes: bytes, filename: 'nexflo_backup.json');
    Get.snackbar('Exported', 'Backup saved', snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> clearAllData() async {
    final first = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete ALL your data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Continue', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (first != true) return;

    final second = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('All wallets, transactions, budgets, goals and debts will be deleted.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Yes, delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (second != true) return;

    final third = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text('Type "DELETE" to confirm.'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('DELETE EVERYTHING', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (third != true) return;

    final db = Get.find<AppDatabase>();
    await db.transaction(() async {
      await db.delete(db.transactions).go();
      await db.delete(db.wallets).go();
      await db.delete(db.budgets).go();
      await db.delete(db.goals).go();
      await db.delete(db.debts).go();
      await db.delete(db.debtPayments).go();
      await db.delete(db.recurringTransactions).go();
      await db.delete(db.syncQueue).go();
    });

    Get.snackbar('Cleared', 'All data has been deleted',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white);
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
