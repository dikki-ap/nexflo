import 'package:drift/drift.dart';

class CurrencyRates extends Table {
  TextColumn get id => text()();
  TextColumn get fromCurrency => text()();
  TextColumn get toCurrency => text()();
  RealColumn get rate => real()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
