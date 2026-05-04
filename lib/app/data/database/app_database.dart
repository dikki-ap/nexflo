import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/users_table.dart';
import 'tables/wallets_table.dart';
import 'tables/transactions_table.dart';
import 'tables/categories_table.dart';
import 'tables/subcategories_table.dart';
import 'tables/budgets_table.dart';
import 'tables/goals_table.dart';
import 'tables/debts_table.dart';
import 'tables/debt_payments_table.dart';
import 'tables/recurring_transactions_table.dart';
import 'tables/currencies_table.dart';
import 'tables/currency_rates_table.dart';
import 'tables/settings_table.dart';
import 'tables/sync_queue_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  Wallets,
  Transactions,
  Categories,
  Subcategories,
  Budgets,
  Goals,
  Debts,
  DebtPayments,
  RecurringTransactions,
  Currencies,
  CurrencyRates,
  Settings,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'nexflo_db');
}
