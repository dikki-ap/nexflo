import 'package:drift/drift.dart';
import 'users_table.dart';
import 'wallets_table.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get toWalletId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get subcategoryId => text().nullable()();
  TextColumn get type => text()();
  RealColumn get amount => real()();
  RealColumn get originalAmount => real().nullable()();
  TextColumn get originalCurrency => text().nullable()();
  RealColumn get exchangeRate => real().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  TextColumn get receiptImagePath => text().nullable()();
  BoolColumn get isRecurring =>
      boolean().withDefault(const Constant(false))();
  TextColumn get recurringId => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
