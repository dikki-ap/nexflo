import 'package:drift/drift.dart';
import 'users_table.dart';

class Debts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get type => text()();
  TextColumn get personName => text()();
  RealColumn get amount => real()();
  RealColumn get paidAmount =>
      real().withDefault(const Constant(0))();
  TextColumn get currencyCode => text()();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('active'))();
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
