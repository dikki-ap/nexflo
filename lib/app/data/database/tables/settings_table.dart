import 'package:drift/drift.dart';
import 'users_table.dart';

class Settings extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id).unique()();
  TextColumn get baseCurrencyCode =>
      text().withDefault(const Constant('USD'))();
  IntColumn get cutoffDate =>
      integer().withDefault(const Constant(1))();
  TextColumn get themeMode =>
      text().withDefault(const Constant('system'))();
  TextColumn get themeColor =>
      text().withDefault(const Constant('teal'))();
  TextColumn get themeCustomHex => text().nullable()();
  BoolColumn get isBiometricEnabled =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isPinEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get pinHash => text().nullable()();
  TextColumn get sheetsSpreadsheetId => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  BoolColumn get syncEnabled =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get notificationBudgetAlert =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get notificationRecurringReminder =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get notificationDebtReminder =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
