import 'package:equatable/equatable.dart';

class CurrencyEntity extends Equatable {
  final String code;
  final String name;
  final String symbol;
  final String flagEmoji;
  final bool isActive;

  const CurrencyEntity({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flagEmoji,
    required this.isActive,
  });

  @override
  List<Object> get props => [code];
}
