import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/errors/exceptions.dart';

class CurrencyRateRemoteDataSource {
  static const _baseUrl = 'https://api.frankfurter.app';

  Future<Map<String, double>> fetchLatestRates(String baseCurrency) async {
    try {
      final uri = Uri.parse('$_baseUrl/latest?from=$baseCurrency');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw NetworkException(
          'Failed to fetch rates: HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = data['rates'] as Map<String, dynamic>;

      return {for (final e in rates.entries) e.key: (e.value as num).toDouble()};
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to fetch currency rates: $e');
    }
  }
}
