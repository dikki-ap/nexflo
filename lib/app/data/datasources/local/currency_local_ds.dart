import 'package:drift/drift.dart';
import '../../database/app_database.dart';
import '../../../core/errors/exceptions.dart';

class CurrencyLocalDataSource {
  final AppDatabase _db;
  CurrencyLocalDataSource(this._db);

  Future<List<Currency>> getAll() async {
    try {
      return await (_db.select(_db.currencies)
            ..where((c) => c.isActive.equals(true))
            ..orderBy([(c) => OrderingTerm.asc(c.code)]))
          .get();
    } catch (e) {
      throw LocalDatabaseException('Failed to get currencies: $e');
    }
  }

  Future<Currency?> getByCode(String code) async {
    try {
      return await (_db.select(_db.currencies)
            ..where((c) => c.code.equals(code)))
          .getSingleOrNull();
    } catch (e) {
      throw LocalDatabaseException('Failed to get currency: $e');
    }
  }

  Future<bool> isSeeded() async {
    final count = await _db.select(_db.currencies).get();
    return count.isNotEmpty;
  }

  Future<void> seedCurrencies() async {
    if (await isSeeded()) return;

    const currencies = [
      ('USD', 'US Dollar', '\$', '🇺🇸'),
      ('EUR', 'Euro', '€', '🇪🇺'),
      ('GBP', 'British Pound', '£', '🇬🇧'),
      ('JPY', 'Japanese Yen', '¥', '🇯🇵'),
      ('SGD', 'Singapore Dollar', 'S\$', '🇸🇬'),
      ('MYR', 'Malaysian Ringgit', 'RM', '🇲🇾'),
      ('IDR', 'Indonesian Rupiah', 'Rp', '🇮🇩'),
      ('AUD', 'Australian Dollar', 'A\$', '🇦🇺'),
      ('CAD', 'Canadian Dollar', 'C\$', '🇨🇦'),
      ('CHF', 'Swiss Franc', 'Fr', '🇨🇭'),
      ('CNY', 'Chinese Yuan', '¥', '🇨🇳'),
      ('HKD', 'Hong Kong Dollar', 'HK\$', '🇭🇰'),
      ('KRW', 'South Korean Won', '₩', '🇰🇷'),
      ('INR', 'Indian Rupee', '₹', '🇮🇳'),
      ('THB', 'Thai Baht', '฿', '🇹🇭'),
      ('PHP', 'Philippine Peso', '₱', '🇵🇭'),
      ('VND', 'Vietnamese Dong', '₫', '🇻🇳'),
      ('TWD', 'New Taiwan Dollar', 'NT\$', '🇹🇼'),
      ('NZD', 'New Zealand Dollar', 'NZ\$', '🇳🇿'),
      ('AED', 'UAE Dirham', 'د.إ', '🇦🇪'),
    ];

    final companions = currencies.map((c) {
      final (code, name, symbol, flag) = c;
      return CurrenciesCompanion.insert(
        code: code,
        name: name,
        symbol: symbol,
        flagEmoji: flag,
      );
    }).toList();

    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.currencies, companions);
    });
  }
}
