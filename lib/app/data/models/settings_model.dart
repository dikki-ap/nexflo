import 'package:drift/drift.dart' show Value;

import '../../core/constants/app_constants.dart';
import '../../core/enums/theme_color.dart';
import '../../core/utils/uuid_helper.dart';
import '../../domain/entities/settings_entity.dart';
import '../database/app_database.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.id,
    required super.userId,
    required super.baseCurrencyCode,
    required super.cutoffDate,
    required super.themeMode,
    required super.themeColor,
    super.themeCustomHex,
    required super.isBiometricEnabled,
    required super.isPinEnabled,
    super.pinHash,
    super.sheetsSpreadsheetId,
    super.lastSyncAt,
    required super.syncEnabled,
    required super.notificationBudgetAlert,
    required super.notificationRecurringReminder,
    required super.notificationDebtReminder,
  });

  factory SettingsModel.fromDrift(Setting s) => SettingsModel(
        id: s.id,
        userId: s.userId,
        baseCurrencyCode: s.baseCurrencyCode,
        cutoffDate: s.cutoffDate,
        themeMode: s.themeMode,
        themeColor: ThemeColor.fromValue(s.themeColor),
        themeCustomHex: s.themeCustomHex,
        isBiometricEnabled: s.isBiometricEnabled,
        isPinEnabled: s.isPinEnabled,
        pinHash: s.pinHash,
        sheetsSpreadsheetId: s.sheetsSpreadsheetId,
        lastSyncAt: s.lastSyncAt,
        syncEnabled: s.syncEnabled,
        notificationBudgetAlert: s.notificationBudgetAlert,
        notificationRecurringReminder: s.notificationRecurringReminder,
        notificationDebtReminder: s.notificationDebtReminder,
      );

  static SettingsModel defaultFor(String userId) => SettingsModel(
        id: UuidHelper.generate(),
        userId: userId,
        baseCurrencyCode: defaultCurrencyCode,
        cutoffDate: defaultCutoffDate,
        themeMode: defaultThemeMode,
        themeColor: ThemeColor.teal,
        isBiometricEnabled: false,
        isPinEnabled: false,
        syncEnabled: true,
        notificationBudgetAlert: true,
        notificationRecurringReminder: true,
        notificationDebtReminder: true,
      );

  @override
  SettingsModel copyWith({
    String? baseCurrencyCode,
    int? cutoffDate,
    String? themeMode,
    ThemeColor? themeColor,
    String? themeCustomHex,
    bool? isBiometricEnabled,
    bool? isPinEnabled,
    String? pinHash,
    String? sheetsSpreadsheetId,
    DateTime? lastSyncAt,
    bool? syncEnabled,
    bool? notificationBudgetAlert,
    bool? notificationRecurringReminder,
    bool? notificationDebtReminder,
  }) =>
      SettingsModel(
        id: id,
        userId: userId,
        baseCurrencyCode: baseCurrencyCode ?? this.baseCurrencyCode,
        cutoffDate: cutoffDate ?? this.cutoffDate,
        themeMode: themeMode ?? this.themeMode,
        themeColor: themeColor ?? this.themeColor,
        themeCustomHex: themeCustomHex ?? this.themeCustomHex,
        isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
        isPinEnabled: isPinEnabled ?? this.isPinEnabled,
        pinHash: pinHash ?? this.pinHash,
        sheetsSpreadsheetId: sheetsSpreadsheetId ?? this.sheetsSpreadsheetId,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        syncEnabled: syncEnabled ?? this.syncEnabled,
        notificationBudgetAlert:
            notificationBudgetAlert ?? this.notificationBudgetAlert,
        notificationRecurringReminder:
            notificationRecurringReminder ?? this.notificationRecurringReminder,
        notificationDebtReminder:
            notificationDebtReminder ?? this.notificationDebtReminder,
      );

  SettingsCompanion toCompanion() => SettingsCompanion(
        id: Value(id),
        userId: Value(userId),
        baseCurrencyCode: Value(baseCurrencyCode),
        cutoffDate: Value(cutoffDate),
        themeMode: Value(themeMode),
        themeColor: Value(themeColor.value),
        themeCustomHex: Value(themeCustomHex),
        isBiometricEnabled: Value(isBiometricEnabled),
        isPinEnabled: Value(isPinEnabled),
        pinHash: Value(pinHash),
        sheetsSpreadsheetId: Value(sheetsSpreadsheetId),
        lastSyncAt: Value(lastSyncAt),
        syncEnabled: Value(syncEnabled),
        notificationBudgetAlert: Value(notificationBudgetAlert),
        notificationRecurringReminder: Value(notificationRecurringReminder),
        notificationDebtReminder: Value(notificationDebtReminder),
      );
}
