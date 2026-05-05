import 'package:drift/drift.dart' show Value;
import 'package:get/get.dart';

import '../data/database/app_database.dart';
import '../data/datasources/local/settings_local_ds.dart';
import '../data/datasources/remote/sheets_remote_ds.dart';
import '../core/constants/sheets_constants.dart';
import 'auth_service.dart';

enum SyncState { idle, syncing, success, error }

class SyncService extends GetxService {
  final AppDatabase _db;
  SyncService(this._db);

  late final SheetsRemoteDataSource _sheetsDs;
  late final SettingsLocalDataSource _settingsDs;

  final _syncState = SyncState.idle.obs;
  SyncState get syncState => _syncState.value;
  bool get isSyncing => _syncState.value == SyncState.syncing;

  Future<SyncService> init() async {
    _sheetsDs = SheetsRemoteDataSource();
    _settingsDs = SettingsLocalDataSource(_db);
    return this;
  }

  Future<void> sync() async {
    if (_syncState.value == SyncState.syncing) return;
    _syncState.value = SyncState.syncing;
    try {
      final userId = Get.find<AuthService>().currentUser?.id;
      final userEmail = Get.find<AuthService>().currentUser?.email ?? '';
      if (userId == null) {
        _syncState.value = SyncState.idle;
        return;
      }

      final settings = await _settingsDs.getByUserId(userId);
      if (settings == null || !settings.syncEnabled) {
        _syncState.value = SyncState.idle;
        return;
      }

      final spreadsheetId =
          await _ensureSpreadsheet(settings.sheetsSpreadsheetId, userId, userEmail);

      await _pullFromSheets(spreadsheetId, userId);
      await _pushPendingEntities(spreadsheetId, userId);
      await _updateLastSyncAt(userId, spreadsheetId);

      _syncState.value = SyncState.success;
    } catch (_) {
      _syncState.value = SyncState.error;
    }
  }

  // ── Spreadsheet Setup ────────────────────────────────────────────────────

  Future<String> _ensureSpreadsheet(
    String? existingId,
    String userId,
    String userEmail,
  ) async {
    if (existingId != null && existingId.isNotEmpty) return existingId;

    final newId = await _sheetsDs.createSpreadsheet(
      title: SheetsConstants.spreadsheetName,
      userEmail: userEmail,
    );

    // Persist spreadsheet ID to settings
    final settings = await _settingsDs.getByUserId(userId);
    if (settings != null) {
      await _settingsDs.update(settings.copyWith(sheetsSpreadsheetId: newId));
    }
    return newId;
  }

  // ── Pull (Remote → Local) ────────────────────────────────────────────────

  Future<void> _pullFromSheets(String spreadsheetId, String userId) async {
    await Future.wait([
      _pullSheet(spreadsheetId, SheetsConstants.sheetWallets, userId, _pullWalletRow),
      _pullSheet(spreadsheetId, SheetsConstants.sheetCategories, userId, _pullCategoryRow),
      _pullSheet(spreadsheetId, SheetsConstants.sheetSubcategories, userId, _pullSubcategoryRow),
      _pullSheet(spreadsheetId, SheetsConstants.sheetTransactions, userId, _pullTransactionRow),
      _pullSheet(spreadsheetId, SheetsConstants.sheetBudgets, userId, _pullBudgetRow),
      _pullSheet(spreadsheetId, SheetsConstants.sheetGoals, userId, _pullGoalRow),
      _pullSheet(spreadsheetId, SheetsConstants.sheetDebts, userId, _pullDebtRow),
    ]);
  }

  Future<void> _pullSheet(
    String spreadsheetId,
    String sheetName,
    String userId,
    Future<void> Function(List<String>, String) rowHandler,
  ) async {
    try {
      final rows = await _sheetsDs.getRows(spreadsheetId, sheetName);
      for (final row in rows) {
        if (row.isEmpty) continue;
        await rowHandler(row, userId);
      }
    } catch (_) {
      // Non-fatal: skip this sheet on error
    }
  }

  Future<void> _pullWalletRow(List<String> r, String userId) async {
    if (r.length < 14 || r[1] != userId) return;
    final remoteUpdated = DateTime.tryParse(r[13]);
    if (remoteUpdated == null) return;

    final local = await (_db.select(_db.wallets)
          ..where((w) => w.id.equals(r[0])))
        .getSingleOrNull();
    if (local != null && local.syncStatus == 'pending') return;
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    final companion = WalletsCompanion(
      id: Value(r[0]),
      userId: Value(r[1]),
      name: Value(r[2]),
      type: Value(r[3]),
      colorHex: Value(r[4]),
      iconName: Value(r[5]),
      balance: Value(double.tryParse(r[6]) ?? 0),
      currencyCode: Value(r[7]),
      creditLimit: Value(double.tryParse(r[8])),
      isExcludeTotal: Value(r[9] == 'true'),
      sortOrder: Value(int.tryParse(r[10]) ?? 0),
      isArchived: Value(r[11] == 'true'),
      createdAt: Value(DateTime.tryParse(r[12]) ?? DateTime.now()),
      updatedAt: Value(remoteUpdated),
      deletedAt: Value(r.length > 14 && r[14].isNotEmpty ? DateTime.tryParse(r[14]) : null),
      syncStatus: const Value('synced'),
      version: Value(int.tryParse(r.length > 15 ? r[15] : '') ?? 1),
    );
    await _db.into(_db.wallets)
        .insert(companion, mode: InsertMode.insertOrReplace);
  }

  Future<void> _pullCategoryRow(List<String> r, String userId) async {
    if (r.length < 11 || r[1] != userId) return;
    final remoteUpdated = DateTime.tryParse(r[10]);
    if (remoteUpdated == null) return;

    final local = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(r[0])))
        .getSingleOrNull();
    if (local != null && local.syncStatus == 'pending') return;
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.into(_db.categories).insert(
          CategoriesCompanion(
            id: Value(r[0]),
            userId: Value(r[1]),
            name: Value(r[2]),
            type: Value(r[3]),
            iconName: Value(r[4]),
            colorHex: Value(r[5]),
            isDefault: Value(r[6] == 'true'),
            sortOrder: Value(int.tryParse(r[7]) ?? 0),
            isArchived: Value(r[8] == 'true'),
            createdAt: Value(DateTime.tryParse(r[9]) ?? DateTime.now()),
            updatedAt: Value(remoteUpdated),
            deletedAt: Value(r.length > 11 && r[11].isNotEmpty ? DateTime.tryParse(r[11]) : null),
            syncStatus: const Value('synced'),
            version: Value(int.tryParse(r.length > 12 ? r[12] : '') ?? 1),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _pullSubcategoryRow(List<String> r, String userId) async {
    if (r.length < 11 || r[2] != userId) return;
    final remoteUpdated = DateTime.tryParse(r[10]);
    if (remoteUpdated == null) return;

    final local = await (_db.select(_db.subcategories)
          ..where((s) => s.id.equals(r[0])))
        .getSingleOrNull();
    if (local != null && local.syncStatus == 'pending') return;
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.into(_db.subcategories).insert(
          SubcategoriesCompanion(
            id: Value(r[0]),
            categoryId: Value(r[1]),
            userId: Value(r[2]),
            name: Value(r[3]),
            iconName: Value(r[4]),
            colorHex: Value(r[5]),
            isDefault: Value(r[6] == 'true'),
            sortOrder: Value(int.tryParse(r[7]) ?? 0),
            isArchived: Value(r[8] == 'true'),
            createdAt: Value(DateTime.tryParse(r[9]) ?? DateTime.now()),
            updatedAt: Value(remoteUpdated),
            deletedAt: Value(r.length > 11 && r[11].isNotEmpty ? DateTime.tryParse(r[11]) : null),
            syncStatus: const Value('synced'),
            version: Value(int.tryParse(r.length > 12 ? r[12] : '') ?? 1),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _pullTransactionRow(List<String> r, String userId) async {
    if (r.length < 18 || r[1] != userId) return;
    final remoteUpdated = DateTime.tryParse(r[17]);
    if (remoteUpdated == null) return;

    final local = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(r[0])))
        .getSingleOrNull();
    if (local != null && local.syncStatus == 'pending') return;
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.into(_db.transactions).insert(
          TransactionsCompanion(
            id: Value(r[0]),
            userId: Value(r[1]),
            walletId: Value(r[2]),
            toWalletId: Value(r[3].isNotEmpty ? r[3] : null),
            categoryId: Value(r[4].isNotEmpty ? r[4] : null),
            subcategoryId: Value(r[5].isNotEmpty ? r[5] : null),
            type: Value(r[6]),
            amount: Value(double.tryParse(r[7]) ?? 0),
            originalAmount: Value(double.tryParse(r[8])),
            originalCurrency: Value(r[9].isNotEmpty ? r[9] : null),
            exchangeRate: Value(double.tryParse(r[10])),
            note: Value(r[11].isNotEmpty ? r[11] : null),
            date: Value(DateTime.tryParse(r[12]) ?? DateTime.now()),
            receiptImagePath: Value(r[13].isNotEmpty ? r[13] : null),
            isRecurring: Value(r[14] == 'true'),
            recurringId: Value(r[15].isNotEmpty ? r[15] : null),
            createdAt: Value(DateTime.tryParse(r[16]) ?? DateTime.now()),
            updatedAt: Value(remoteUpdated),
            deletedAt: Value(r.length > 18 && r[18].isNotEmpty ? DateTime.tryParse(r[18]) : null),
            syncStatus: const Value('synced'),
            version: Value(int.tryParse(r.length > 19 ? r[19] : '') ?? 1),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _pullBudgetRow(List<String> r, String userId) async {
    if (r.length < 12 || r[1] != userId) return;
    final remoteUpdated = DateTime.tryParse(r[11]);
    if (remoteUpdated == null) return;

    final local = await (_db.select(_db.budgets)
          ..where((b) => b.id.equals(r[0])))
        .getSingleOrNull();
    if (local != null && local.syncStatus == 'pending') return;
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.into(_db.budgets).insert(
          BudgetsCompanion(
            id: Value(r[0]),
            userId: Value(r[1]),
            name: Value(r[2]),
            amount: Value(double.tryParse(r[3]) ?? 0),
            period: Value(r[4]),
            categoryId: Value(r[5].isNotEmpty ? r[5] : null),
            walletId: Value(r[6].isNotEmpty ? r[6] : null),
            isAllCategories: Value(r[7] == 'true'),
            rollover: Value(r[8] == 'true'),
            alertAtPercent: Value(int.tryParse(r[9]) ?? 80),
            createdAt: Value(DateTime.tryParse(r[10]) ?? DateTime.now()),
            updatedAt: Value(remoteUpdated),
            deletedAt: Value(r.length > 12 && r[12].isNotEmpty ? DateTime.tryParse(r[12]) : null),
            syncStatus: const Value('synced'),
            version: Value(int.tryParse(r.length > 13 ? r[13] : '') ?? 1),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _pullGoalRow(List<String> r, String userId) async {
    if (r.length < 13 || r[1] != userId) return;
    final remoteUpdated = DateTime.tryParse(r[12]);
    if (remoteUpdated == null) return;

    final local = await (_db.select(_db.goals)
          ..where((g) => g.id.equals(r[0])))
        .getSingleOrNull();
    if (local != null && local.syncStatus == 'pending') return;
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.into(_db.goals).insert(
          GoalsCompanion(
            id: Value(r[0]),
            userId: Value(r[1]),
            walletId: Value(r[2].isNotEmpty ? r[2] : null),
            name: Value(r[3]),
            iconName: Value(r[4]),
            colorHex: Value(r[5]),
            targetAmount: Value(double.tryParse(r[6]) ?? 0),
            currentAmount: Value(double.tryParse(r[7]) ?? 0),
            deadline: Value(r[8].isNotEmpty ? DateTime.tryParse(r[8]) : null),
            status: Value(r[9]),
            note: Value(r[10].isNotEmpty ? r[10] : null),
            createdAt: Value(DateTime.tryParse(r[11]) ?? DateTime.now()),
            updatedAt: Value(remoteUpdated),
            deletedAt: Value(r.length > 13 && r[13].isNotEmpty ? DateTime.tryParse(r[13]) : null),
            syncStatus: const Value('synced'),
            version: Value(int.tryParse(r.length > 14 ? r[14] : '') ?? 1),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  Future<void> _pullDebtRow(List<String> r, String userId) async {
    if (r.length < 12 || r[1] != userId) return;
    final remoteUpdated = DateTime.tryParse(r[11]);
    if (remoteUpdated == null) return;

    final local = await (_db.select(_db.debts)
          ..where((d) => d.id.equals(r[0])))
        .getSingleOrNull();
    if (local != null && local.syncStatus == 'pending') return;
    if (local != null && !remoteUpdated.isAfter(local.updatedAt)) return;

    await _db.into(_db.debts).insert(
          DebtsCompanion(
            id: Value(r[0]),
            userId: Value(r[1]),
            type: Value(r[2]),
            personName: Value(r[3]),
            amount: Value(double.tryParse(r[4]) ?? 0),
            paidAmount: Value(double.tryParse(r[5]) ?? 0),
            currencyCode: Value(r[6]),
            deadline: Value(r[7].isNotEmpty ? DateTime.tryParse(r[7]) : null),
            note: Value(r[8].isNotEmpty ? r[8] : null),
            status: Value(r[9]),
            createdAt: Value(DateTime.tryParse(r[10]) ?? DateTime.now()),
            updatedAt: Value(remoteUpdated),
            deletedAt: Value(r.length > 12 && r[12].isNotEmpty ? DateTime.tryParse(r[12]) : null),
            syncStatus: const Value('synced'),
            version: Value(int.tryParse(r.length > 13 ? r[13] : '') ?? 1),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  // ── Push (Local → Remote) ────────────────────────────────────────────────

  Future<void> _pushPendingEntities(String spreadsheetId, String userId) async {
    await _pushWallets(spreadsheetId, userId);
    await _pushCategories(spreadsheetId, userId);
    await _pushSubcategories(spreadsheetId, userId);
    await _pushTransactions(spreadsheetId, userId);
    await _pushBudgets(spreadsheetId, userId);
    await _pushGoals(spreadsheetId, userId);
    await _pushDebts(spreadsheetId, userId);
    await _pushRecurring(spreadsheetId, userId);
  }

  Future<void> _pushWallets(String spreadsheetId, String userId) async {
    final pending = await (_db.select(_db.wallets)
          ..where((w) => w.userId.equals(userId))
          ..where((w) => w.syncStatus.equals('pending')))
        .get();
    for (final w in pending) {
      await _sheetsDs.upsertRow(spreadsheetId, SheetsConstants.sheetWallets, w.id, [
        w.id, w.userId, w.name, w.type, w.colorHex, w.iconName,
        w.balance.toString(), w.currencyCode, w.creditLimit?.toString() ?? '',
        w.isExcludeTotal.toString(), w.sortOrder.toString(), w.isArchived.toString(),
        w.createdAt.toIso8601String(), w.updatedAt.toIso8601String(),
        w.deletedAt?.toIso8601String() ?? '', '1',
      ]);
      await (_db.update(_db.wallets)..where((w2) => w2.id.equals(w.id)))
          .write(const WalletsCompanion(syncStatus: Value('synced')));
    }
  }

  Future<void> _pushCategories(String spreadsheetId, String userId) async {
    final pending = await (_db.select(_db.categories)
          ..where((c) => c.userId.equals(userId))
          ..where((c) => c.syncStatus.equals('pending')))
        .get();
    for (final c in pending) {
      await _sheetsDs.upsertRow(spreadsheetId, SheetsConstants.sheetCategories, c.id, [
        c.id, c.userId, c.name, c.type, c.iconName, c.colorHex,
        c.isDefault.toString(), c.sortOrder.toString(), c.isArchived.toString(),
        c.createdAt.toIso8601String(), c.updatedAt.toIso8601String(),
        c.deletedAt?.toIso8601String() ?? '', '1',
      ]);
      await (_db.update(_db.categories)..where((c2) => c2.id.equals(c.id)))
          .write(const CategoriesCompanion(syncStatus: Value('synced')));
    }
  }

  Future<void> _pushSubcategories(String spreadsheetId, String userId) async {
    final pending = await (_db.select(_db.subcategories)
          ..where((s) => s.userId.equals(userId))
          ..where((s) => s.syncStatus.equals('pending')))
        .get();
    for (final s in pending) {
      await _sheetsDs.upsertRow(spreadsheetId, SheetsConstants.sheetSubcategories, s.id, [
        s.id, s.categoryId, s.userId, s.name, s.iconName, s.colorHex,
        s.isDefault.toString(), s.sortOrder.toString(), s.isArchived.toString(),
        s.createdAt.toIso8601String(), s.updatedAt.toIso8601String(),
        s.deletedAt?.toIso8601String() ?? '', '1',
      ]);
      await (_db.update(_db.subcategories)..where((s2) => s2.id.equals(s.id)))
          .write(const SubcategoriesCompanion(syncStatus: Value('synced')));
    }
  }

  Future<void> _pushTransactions(String spreadsheetId, String userId) async {
    final pending = await (_db.select(_db.transactions)
          ..where((t) => t.userId.equals(userId))
          ..where((t) => t.syncStatus.equals('pending')))
        .get();
    for (final t in pending) {
      await _sheetsDs.upsertRow(spreadsheetId, SheetsConstants.sheetTransactions, t.id, [
        t.id, t.userId, t.walletId, t.toWalletId ?? '', t.categoryId ?? '',
        t.subcategoryId ?? '', t.type, t.amount.toString(),
        t.originalAmount?.toString() ?? '', t.originalCurrency ?? '',
        t.exchangeRate?.toString() ?? '', t.note ?? '',
        t.date.toIso8601String(), t.receiptImagePath ?? '',
        t.isRecurring.toString(), t.recurringId ?? '',
        t.createdAt.toIso8601String(), t.updatedAt.toIso8601String(),
        t.deletedAt?.toIso8601String() ?? '', t.version.toString(),
      ]);
      await (_db.update(_db.transactions)..where((t2) => t2.id.equals(t.id)))
          .write(const TransactionsCompanion(syncStatus: Value('synced')));
    }
  }

  Future<void> _pushBudgets(String spreadsheetId, String userId) async {
    final pending = await (_db.select(_db.budgets)
          ..where((b) => b.userId.equals(userId))
          ..where((b) => b.syncStatus.equals('pending')))
        .get();
    for (final b in pending) {
      await _sheetsDs.upsertRow(spreadsheetId, SheetsConstants.sheetBudgets, b.id, [
        b.id, b.userId, b.name, b.amount.toString(), b.period,
        b.categoryId ?? '', b.walletId ?? '', b.isAllCategories.toString(),
        b.rollover.toString(), b.alertAtPercent.toString(),
        b.createdAt.toIso8601String(), b.updatedAt.toIso8601String(),
        b.deletedAt?.toIso8601String() ?? '', '1',
      ]);
      await (_db.update(_db.budgets)..where((b2) => b2.id.equals(b.id)))
          .write(const BudgetsCompanion(syncStatus: Value('synced')));
    }
  }

  Future<void> _pushGoals(String spreadsheetId, String userId) async {
    final pending = await (_db.select(_db.goals)
          ..where((g) => g.userId.equals(userId))
          ..where((g) => g.syncStatus.equals('pending')))
        .get();
    for (final g in pending) {
      await _sheetsDs.upsertRow(spreadsheetId, SheetsConstants.sheetGoals, g.id, [
        g.id, g.userId, g.walletId ?? '', g.name, g.iconName, g.colorHex,
        g.targetAmount.toString(), g.currentAmount.toString(),
        g.deadline?.toIso8601String() ?? '', g.status, g.note ?? '',
        g.createdAt.toIso8601String(), g.updatedAt.toIso8601String(),
        g.deletedAt?.toIso8601String() ?? '', '1',
      ]);
      await (_db.update(_db.goals)..where((g2) => g2.id.equals(g.id)))
          .write(const GoalsCompanion(syncStatus: Value('synced')));
    }
  }

  Future<void> _pushDebts(String spreadsheetId, String userId) async {
    final pending = await (_db.select(_db.debts)
          ..where((d) => d.userId.equals(userId))
          ..where((d) => d.syncStatus.equals('pending')))
        .get();
    for (final d in pending) {
      await _sheetsDs.upsertRow(spreadsheetId, SheetsConstants.sheetDebts, d.id, [
        d.id, d.userId, d.type, d.personName, d.amount.toString(),
        d.paidAmount.toString(), d.currencyCode, d.deadline?.toIso8601String() ?? '',
        d.note ?? '', d.status, d.createdAt.toIso8601String(),
        d.updatedAt.toIso8601String(), d.deletedAt?.toIso8601String() ?? '', '1',
      ]);
      await (_db.update(_db.debts)..where((d2) => d2.id.equals(d.id)))
          .write(const DebtsCompanion(syncStatus: Value('synced')));
    }
  }

  Future<void> _pushRecurring(String spreadsheetId, String userId) async {
    final pending = await (_db.select(_db.recurringTransactions)
          ..where((r) => r.userId.equals(userId))
          ..where((r) => r.syncStatus.equals('pending')))
        .get();
    for (final r in pending) {
      await _sheetsDs.upsertRow(spreadsheetId, SheetsConstants.sheetRecurring, r.id, [
        r.id, r.userId, r.walletId, r.toWalletId ?? '', r.categoryId ?? '',
        r.subcategoryId ?? '', r.type, r.amount.toString(), r.note ?? '',
        r.recurrenceType, r.recurrenceInterval.toString(),
        r.startDate.toIso8601String(), r.endDate?.toIso8601String() ?? '',
        r.nextDueDate.toIso8601String(),
        r.lastProcessedDate?.toIso8601String() ?? '',
        r.isActive.toString(), r.createdAt.toIso8601String(),
        r.updatedAt.toIso8601String(),
        r.deletedAt?.toIso8601String() ?? '', r.version.toString(),
      ]);
      await (_db.update(_db.recurringTransactions)
            ..where((r2) => r2.id.equals(r.id)))
          .write(const RecurringTransactionsCompanion(syncStatus: Value('synced')));
    }
  }

  // ── Meta ─────────────────────────────────────────────────────────────────

  Future<void> _updateLastSyncAt(String userId, String spreadsheetId) async {
    final now = DateTime.now();
    final settings = await _settingsDs.getByUserId(userId);
    if (settings != null) {
      await _settingsDs.update(settings.copyWith(lastSyncAt: now));
    }
    await _sheetsDs.updateMetaLastSync(spreadsheetId, now.toIso8601String());
  }

  DateTime? lastSyncAt(String userId) => null; // Fetched live from settings
}
