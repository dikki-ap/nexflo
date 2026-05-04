enum GoalStatus {
  active,
  completed,
  cancelled;

  String get value => name;

  static GoalStatus fromValue(String value) =>
      GoalStatus.values.firstWhere((e) => e.name == value);
}
