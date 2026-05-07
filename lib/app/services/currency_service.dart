import 'package:get/get.dart';
import '../data/database/app_database.dart';
import '../data/datasources/local/currency_local_ds.dart';
import '../data/datasources/local/currency_rate_local_ds.dart';
import '../data/datasources/remote/currency_rate_remote_ds.dart';

class CurrencyService extends GetxService {
  final AppDatabase _db;
  CurrencyService(this._db);

  late final CurrencyLocalDataSource _currencyDs;
  late final CurrencyRateLocalDataSource _rateDs;
  late final CurrencyRateRemoteDataSource _remoteDs;

  final _rates = <String, Map<String, double>>{}.obs;
  String _baseCurrency = 'USD';

  Future<CurrencyService> init() async {
    _currencyDs = CurrencyLocalDataSource(_db);
    _rateDs = CurrencyRateLocalDataSource(_db);
    _remoteDs = CurrencyRateRemoteDataSource();

    await _currencyDs.seedCurrencies();
    await _loadCachedRates();
    await _refreshIfStale();

    return this;
  }

  void setBaseCurrency(String code) {
    _baseCurrency = code;
    _loadCachedRates();
  }

  Future<void> _loadCachedRates() async {
    try {
      final rates = await _rateDs.getAllRatesFrom(_baseCurrency);
      _rates[_baseCurrency] = rates;
    } catch (_) {}
  }

  Future<void> _refreshIfStale() async {
    try {
      final lastFetch = await _rateDs.getLastFetchedAt(_baseCurrency);
      final isStale = lastFetch == null ||
          DateTime.now().difference(lastFetch).inHours >= 24;
      if (isStale) await refreshRates();
    } catch (_) {}
  }

  Future<void> refreshRates() async {
    try {
      final rates = await _remoteDs.fetchLatestRates(_baseCurrency);
      await _rateDs.saveRates(fromCurrency: _baseCurrency, rates: rates);
      _rates[_baseCurrency] = rates;
    } catch (_) {
      // Silently use cached rates if network unavailable
    }
  }

  double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    if (fromCurrency == toCurrency) return amount;
    final rates = _rates[_baseCurrency] ?? {};

    // Convert: from → base → to
    final double inBase;
    if (fromCurrency == _baseCurrency) {
      inBase = amount;
    } else {
      final rateFromBase = rates[fromCurrency];
      if (rateFromBase == null || rateFromBase == 0) return amount;
      inBase = amount / rateFromBase;
    }

    if (toCurrency == _baseCurrency) return inBase;
    final rateToTarget = rates[toCurrency];
    if (rateToTarget == null) return amount;
    return inBase * rateToTarget;
  }

  Future<void> setManualRate({
    required String fromCurrency,
    required String toCurrency,
    required double rate,
  }) async {
    await _rateDs.saveManualRate(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: rate,
    );
    await _loadCachedRates();
  }

  Future<String> getSymbol(String currencyCode) async {
    final currency = await _currencyDs.getByCode(currencyCode);
    return currency?.symbol ?? currencyCode;
  }

  static const _symbolMap = {
    'IDR': 'Rp', 'USD': '\$', 'EUR': '€', 'GBP': '£',
    'JPY': '¥', 'CNY': '¥', 'KRW': '₩', 'SGD': 'S\$',
    'MYR': 'RM', 'AUD': 'A\$', 'CAD': 'C\$', 'CHF': 'Fr',
    'HKD': 'HK\$', 'INR': '₹', 'THB': '฿', 'VND': '₫',
    'PHP': '₱', 'TWD': 'NT\$', 'BRL': 'R\$', 'MXN': 'MX\$',
    'ZAR': 'R', 'SEK': 'kr', 'NOK': 'kr', 'DKK': 'kr',
    'SAR': '﷼', 'AED': 'د.إ', 'TRY': '₺', 'RUB': '₽',
  };

  String get currencySymbol => _symbolMap[_baseCurrency] ?? _baseCurrency;
  Map<String, double> get currentRates => _rates[_baseCurrency] ?? {};
  String get baseCurrency => _baseCurrency;

  Future<List<Currency>> getAllCurrencies() => _currencyDs.getAll();
}
