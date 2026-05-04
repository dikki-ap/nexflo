import 'package:intl/intl.dart';

extension DoubleExtension on double {
  String toCurrency({String symbol = '', int decimalDigits = 2}) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  String toCompact() => NumberFormat.compact().format(this);

  String toPercent({int decimalDigits = 1}) =>
      '${toStringAsFixed(decimalDigits)}%';

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
}
