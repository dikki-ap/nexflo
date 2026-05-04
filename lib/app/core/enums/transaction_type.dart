enum TransactionType {
  expense,
  income,
  transfer;

  String get value => name;

  static TransactionType fromValue(String value) =>
      TransactionType.values.firstWhere((e) => e.name == value);
}
