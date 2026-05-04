import 'package:equatable/equatable.dart';
import '../../core/enums/theme_color.dart';

class SettingsEntity extends Equatable {
  final String id;
  final String userId;
  final String baseCurrencyCode;
  final int cutoffDate;
  final String themeMode;
  final ThemeColor themeColor;
  final String? themeCustomHex;
  final bool isBiometricEnabled;
  final bool isPinEnabled;
  final String? pinHash;
  final String? sheetsSpreadsheetId;
  final DateTime? lastSyncAt;
  final bool syncEnabled;
  final bool notificationBudgetAlert;
  final bool notificationRecurringReminder;
  final bool notificationDebtReminder;

  const SettingsEntity({
    required this.id,
    required this.userId,
    required this.baseCurrencyCode,
    required this.cutoffDate,
    required this.themeMode,
    required this.themeColor,
    this.themeCustomHex,
    required this.isBiometricEnabled,
    required this.isPinEnabled,
    this.pinHash,
    this.sheetsSpreadsheetId,
    this.lastSyncAt,
    required this.syncEnabled,
    required this.notificationBudgetAlert,
    required this.notificationRecurringReminder,
    required this.notificationDebtReminder,
  });

  SettingsEntity copyWith({
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
  }) {
    return SettingsEntity(
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
  }

  @override
  List<Object?> get props => [id, userId, baseCurrencyCode, cutoffDate];
}
