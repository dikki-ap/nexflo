import 'package:drift/drift.dart';
import 'users_table.dart';

class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get walletId => text().nullable()();
  TextColumn get name => text()();
  TextColumn get iconName => text()();
  TextColumn get colorHex => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount =>
      real().withDefault(const Constant(0))();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('active'))();
  TextColumn get note => text().nullable()();
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
