import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/utils/uuid_helper.dart';

class CurrencyRateLocalDataSource {
  final AppDatabase _db;
  CurrencyRateLocalDataSource(this._db);

  Future<double?> getRate({
    required String fromCurrency,
    required String toCurrency,
  }) async {
    try {
      final row = await (_db.select(_db.currencyRates)
            ..where((r) =>
                r.fromCurrency.equals(fromCurrency) &
                r.toCurrency.equals(toCurrency))
            ..orderBy([(r) => OrderingTerm.desc(r.fetchedAt)])
            ..limit(1))
          .getSingleOrNull();
      return row?.rate;
    } catch (e) {
      throw LocalDatabaseException('Failed to get rate: $e');
    }
  }

  Future<Map<String, double>> getAllRatesFrom(String fromCurrency) async {
    try {
      final rows = await (_db.select(_db.currencyRates)
            ..where((r) => r.fromCurrency.equals(fromCurrency)))
          .get();

      // Keep only the most recent rate per currency pair
      final Map<String, CurrencyRate> latest = {};
      for (final r in rows) {
        final existing = latest[r.toCurrency];
        if (existing == null || r.fetchedAt.isAfter(existing.fetchedAt)) {
          latest[r.toCurrency] = r;
        }
      }
      return {for (final e in latest.entries) e.key: e.value.rate};
    } catch (e) {
      throw LocalDatabaseException('Failed to get rates: $e');
    }
  }

  Future<DateTime?> getLastFetchedAt(String fromCurrency) async {
    try {
      final row = await (_db.select(_db.currencyRates)
            ..where((r) => r.fromCurrency.equals(fromCurrency))
            ..orderBy([(r) => OrderingTerm.desc(r.fetchedAt)])
            ..limit(1))
          .getSingleOrNull();
      return row?.fetchedAt;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveRates({
    required String fromCurrency,
    required Map<String, double> rates,
  }) async {
    try {
      final now = DateTime.now();
      final companions = rates.entries.map((e) {
        return CurrencyRatesCompanion.insert(
          id: UuidHelper.generate(),
          fromCurrency: fromCurrency,
          toCurrency: e.key,
          rate: e.value,
          fetchedAt: now,
        );
      }).toList();

      await _db.batch((batch) {
        batch.insertAll(_db.currencyRates, companions,
            mode: InsertMode.insertOrReplace);
      });
    } catch (e) {
      throw LocalDatabaseException('Failed to save rates: $e');
    }
  }

  Future<void> saveManualRate({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
  }) async {
    try {
      final companion = CurrencyRatesCompanion.insert(
        id: UuidHelper.generate(),
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        rate: rate,
        fetchedAt: DateTime.now(),
      );
      await _db
          .into(_db.currencyRates)
          .insert(companion, mode: InsertMode.insertOrReplace);
    } catch (e) {
      throw LocalDatabaseException('Failed to save manual rate: $e');
    }
  }
}
