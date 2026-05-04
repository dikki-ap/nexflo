import 'package:drift/drift.dart';

class Currencies extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get symbol => text()();
  TextColumn get flagEmoji => text()();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {code};
}
