import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(
    double amount, {
    required String symbol,
    int decimalDigits = 2,
  }) {
    if (amount.abs() >= 1000000) {
      return '${symbol}${_compactFormat(amount)}';
    }
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(amount);
  }

  static String formatCompact(double amount, {required String symbol}) =>
      '$symbol${NumberFormat.compact().format(amount)}';

  static String _compactFormat(double amount) {
    if (amount.abs() >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    }
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    return amount.toStringAsFixed(0);
  }

  static double parse(String value) =>
      double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0.0;
}
