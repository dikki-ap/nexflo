import 'package:drift/drift.dart';
import 'debts_table.dart';

class DebtPayments extends Table {
  TextColumn get id => text()();
  TextColumn get debtId => text().references(Debts, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}
