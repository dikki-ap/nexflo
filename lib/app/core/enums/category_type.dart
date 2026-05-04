enum CategoryType {
  expense,
  income,
  both;

  String get value => name;

  static CategoryType fromValue(String value) =>
      CategoryType.values.firstWhere((e) => e.name == value);
}
