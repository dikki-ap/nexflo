import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/filter_period.dart';
import '../controllers/statistics_controller.dart';

class StatisticsPage extends GetView<StatisticsController> {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: const Icon(Icons.download_outlined),
                  tooltip: 'Export CSV',
                  onPressed: () => _exportCsv(context),
                )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadAll,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              _PeriodFilter(controller),
              const SizedBox(height: 16),
              _SummaryCards(controller),
              const SizedBox(height: 20),
              if (controller.monthlyData.length > 1) ...[
                _IncomeExpenseChart(controller),
                const SizedBox(height: 20),
              ],
              if (controller.topCategories.isNotEmpty) ...[
                _ExpenseDonutChart(controller),
                const SizedBox(height: 20),
                _TopCategoriesList(controller),
              ],
            ],
          );
        }),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final path = await controller.exportCsv();
    if (path != null) {
      Get.snackbar(
        'Export Complete',
        'Saved to: $path',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } else {
      Get.snackbar('Export Failed', 'No data to export',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class _PeriodFilter extends StatelessWidget {
  final StatisticsController ctrl;
  const _PeriodFilter(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ctrl.filterPeriods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final p = ctrl.filterPeriods[i];
              return FilterChip(
                label: Text(p.label, style: const TextStyle(fontSize: 13)),
                selected: ctrl.selectedPeriod.value == p,
                onSelected: (_) => ctrl.changePeriod(p),
              );
            },
          )),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final StatisticsController ctrl;
  const _SummaryCards(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cashflow = ctrl.cashflow;
      final savingsRate = ctrl.savingsRate;
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.6,
        children: [
          _StatCard(
            label: 'Income',
            value: _fmt(ctrl.totalIncome.value),
            color: AppColors.income,
            icon: Icons.arrow_upward_rounded,
          ),
          _StatCard(
            label: 'Expense',
            value: _fmt(ctrl.totalExpense.value),
            color: AppColors.expense,
            icon: Icons.arrow_downward_rounded,
          ),
          _StatCard(
            label: 'Cashflow',
            value: _fmt(cashflow),
            color: cashflow >= 0 ? AppColors.income : AppColors.expense,
            icon: cashflow >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
          ),
          _StatCard(
            label: 'Savings Rate',
            value: '${savingsRate.toStringAsFixed(1)}%',
            color: savingsRate >= 20
                ? AppColors.income
                : savingsRate >= 0
                    ? AppColors.budgetWarning
                    : AppColors.expense,
            icon: Icons.savings_outlined,
          ),
        ],
      );
    });
  }

  String _fmt(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ],
      ),
    );
  }
}

class _IncomeExpenseChart extends StatelessWidget {
  final StatisticsController ctrl;
  const _IncomeExpenseChart(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final months = ctrl.monthlyData;
    final maxY = months
        .expand((m) => [m.income, m.expense])
        .fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 100.0 : maxY * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Income vs Expense',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 8),
                _Legend(color: AppColors.income, label: 'Income'),
                const SizedBox(width: 12),
                _Legend(color: AppColors.expense, label: 'Expense'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  maxY: chartMax,
                  barGroups: List.generate(months.length, (i) {
                    final m = months[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: m.income,
                          color: AppColors.income,
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: m.expense,
                          color: AppColors.expense,
                          width: 8,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                      barsSpace: 3,
                    );
                  }),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= months.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(months[i].label,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5)));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseDonutChart extends StatelessWidget {
  final StatisticsController ctrl;
  const _ExpenseDonutChart(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final cats = ctrl.topCategories;
    final total = cats.fold(0.0, (s, c) => s + c.amount);
    if (total == 0) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expense by Category',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: PieChart(
                    PieChartData(
                      sections: cats.map((ca) {
                        final pct = ca.amount / total * 100;
                        final color = ctrl.categoryColor(ca);
                        return PieChartSectionData(
                          value: ca.amount,
                          color: color,
                          radius: 52,
                          title: '${pct.toStringAsFixed(0)}%',
                          titleStyle: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600),
                          titlePositionPercentageOffset: 0.6,
                        );
                      }).toList(),
                      centerSpaceRadius: 34,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cats.map((ca) {
                      final color = ctrl.categoryColor(ca);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                ca.category?.name ?? 'Other',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopCategoriesList extends StatelessWidget {
  final StatisticsController ctrl;
  const _TopCategoriesList(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final cats = ctrl.topCategories;
    final maxAmt = cats.isEmpty ? 1.0 : cats.first.amount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Spending',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...cats.map((ca) {
              final color = ctrl.categoryColor(ca);
              final pct = maxAmt > 0 ? ca.amount / maxAmt : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(ca.category?.name ?? 'Uncategorized',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500)),
                        Text(_fmt(ca.amount),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: color)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct.toDouble(),
                        minHeight: 5,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
      ],
    );
  }
}
