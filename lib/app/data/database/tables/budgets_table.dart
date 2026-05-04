import 'package:drift/drift.dart';
import 'users_table.dart';

class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  TextColumn get period => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get walletId => text().nullable()();
  BoolColumn get isAllCategories =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get rollover =>
      boolean().withDefault(const Constant(false))();
  IntColumn get alertAtPercent =>
      integer().withDefault(const Constant(80))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
