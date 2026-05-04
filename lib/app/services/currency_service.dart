import 'package:get/get.dart';
import '../data/database/app_database.dart';
import '../data/datasources/local/currency_local_ds.dart';

class CurrencyService extends GetxService {
  final AppDatabase _db;
  CurrencyService(this._db);

  late final CurrencyLocalDataSource _localDs;

  Future<CurrencyService> init() async {
    _localDs = CurrencyLocalDataSource(_db);
    await _localDs.seedCurrencies();
    return this;
  }

  Future<String> getSymbol(String currencyCode) async {
    final currency = await _localDs.getByCode(currencyCode);
    return currency?.symbol ?? currencyCode;
  }

  // TODO(phase-5): implement Frankfurter API rate fetching and conversion
  double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;
    return amount; // placeholder until Phase 5
  }
}
