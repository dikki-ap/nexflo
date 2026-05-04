enum BudgetPeriod {
  monthly,
  weekly,
  yearly;

  String get value => name;

  static BudgetPeriod fromValue(String value) =>
      BudgetPeriod.values.firstWhere((e) => e.name == value);

  String get label => switch (this) {
        BudgetPeriod.monthly => 'Monthly',
        BudgetPeriod.weekly => 'Weekly',
        BudgetPeriod.yearly => 'Yearly',
      };
}
