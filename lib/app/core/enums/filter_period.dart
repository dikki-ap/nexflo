enum FilterPeriod {
  thisMonth,
  lastMonth,
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  threeYears,
  fiveYears,
  allTime,
  custom;

  String get label => switch (this) {
        FilterPeriod.thisMonth => 'This Month',
        FilterPeriod.lastMonth => 'Last Month',
        FilterPeriod.oneMonth => '1M',
        FilterPeriod.threeMonths => '3M',
        FilterPeriod.sixMonths => '6M',
        FilterPeriod.oneYear => '1Y',
        FilterPeriod.threeYears => '3Y',
        FilterPeriod.fiveYears => '5Y',
        FilterPeriod.allTime => 'All Time',
        FilterPeriod.custom => 'Custom',
      };
}
