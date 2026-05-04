import 'package:drift/drift.dart';
import 'users_table.dart';

class Wallets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get colorHex =>
      text().withDefault(const Constant('#00BCD4'))();
  TextColumn get iconName =>
      text().withDefault(const Constant('wallet'))();
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get currencyCode =>
      text().withDefault(const Constant('USD'))();
  RealColumn get creditLimit => real().nullable()();
  BoolColumn get isExcludeTotal =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
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
