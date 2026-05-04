import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get googleId => text().unique()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get sheetsId => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();

  @override
  Set<Column> get primaryKey => {id};
}
