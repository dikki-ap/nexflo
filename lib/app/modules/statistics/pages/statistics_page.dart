import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../controllers/statistics_controller.dart';
import 'category_detail_page.dart';

class StatisticsPage extends GetView<StatisticsController> {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          Obx(() => controller.isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(strokeWidth: 2),
                  ),
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
        color: Theme.of(context).colorScheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            bottom: false,
            child: Obx(() {
              if (controller.isLoading.value) {
                return ShimmerLoading(
                  isLoading: true,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ShimmerCard(height: 36, horizontalMargin: hPad),
                      const SizedBox(height: 16),
                      ShimmerCard(height: 130, horizontalMargin: hPad),
                      const SizedBox(height: 16),
                      ShimmerCard(height: 220, horizontalMargin: hPad),
                    ],
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _PeriodFilter(controller, hPad, isDark),
                  const SizedBox(height: 16),
                  _SummaryCards(controller, hPad, isDark),
                  const SizedBox(height: 16),
                  if (controller.monthlyData.length > 1) ...[
                    _IncomeExpenseChart(controller, hPad, isDark),
                    const SizedBox(height: 16),
                  ],
                  if (controller.topCategories.isNotEmpty) ...[
                    _ExpenseDonutChart(controller, hPad, isDark),
                    const SizedBox(height: 16),
                    _TopCategoriesList(controller, hPad, isDark),
                  ],
                  const SizedBox(height: 100),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final path = await controller.exportCsv();
    if (path != null) {
      Get.snackbar('Export Complete', 'Saved to: $path',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
    } else {
      Get.snackbar('Export Failed', 'No data to export',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

// ── Period filter ────────────────────────────────────────────────────────────

class _PeriodFilter extends StatelessWidget {
  final StatisticsController ctrl;
  final double hPad;
  final bool isDark;
  const _PeriodFilter(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Obx(() {
        final selected = ctrl.selectedPeriod.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          itemCount: ctrl.filterPeriods.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final p = ctrl.filterPeriods[i];
            final isActive = selected == p;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ctrl.changePeriod(p);
              },
              child: AnimatedContainer(
                duration: AppAnimations.normal,
                curve: AppAnimations.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isActive ? AppColors.primaryGradient(Theme.of(context).colorScheme.primary) : null,
                  color: isActive
                      ? null
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(20),
                  border: isActive
                      ? null
                      : Border.all(
                          color:
                              isDark ? AppColors.grey700 : AppColors.grey200,
                          width: 1,
                        ),
                ),
                child: Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? Colors.white
                        : (isDark ? AppColors.grey400 : AppColors.grey500),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Summary cards ────────────────────────────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  final StatisticsController ctrl;
  final double hPad;
  final bool isDark;
  const _SummaryCards(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cashflow = ctrl.cashflow;
      final savingsRate = ctrl.savingsRate;
      final savingsColor = savingsRate >= 20
          ? AppColors.income
          : savingsRate >= 0
              ? AppColors.budgetWarning
              : AppColors.expense;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          children: [
            _StatCard(
              label: 'Income',
              value: _fmt(ctrl.totalIncome.value),
              color: AppColors.income,
              icon: Icons.arrow_upward_rounded,
              isDark: isDark,
            ),
            _StatCard(
              label: 'Expense',
              value: _fmt(ctrl.totalExpense.value),
              color: AppColors.expense,
              icon: Icons.arrow_downward_rounded,
              isDark: isDark,
            ),
            _StatCard(
              label: 'Cashflow',
              value: _fmt(cashflow),
              color: cashflow >= 0 ? AppColors.income : AppColors.expense,
              icon: cashflow >= 0
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              isDark: isDark,
            ),
            _StatCard(
              label: 'Savings Rate',
              value: '${savingsRate.toStringAsFixed(1)}%',
              color: savingsColor,
              icon: Icons.savings_outlined,
              isDark: isDark,
            ),
          ],
        ),
      );
    });
  }

  String _fmt(double v) {
    final abs = v.abs();
    if (abs >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (abs >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      color: color.withValues(alpha: isDark ? 0.1 : 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 15),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: color.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Income vs Expense bar chart ──────────────────────────────────────────────

class _IncomeExpenseChart extends StatelessWidget {
  final StatisticsController ctrl;
  final double hPad;
  final bool isDark;
  const _IncomeExpenseChart(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    final months = ctrl.monthlyData;
    final maxY = months
        .expand((m) => [m.income, m.expense])
        .fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxY <= 0 ? 100.0 : maxY * 1.2;
    final labelColor =
        isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.grey400;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Income vs Expense',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.grey900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 4),
                _Legend(color: AppColors.income, label: 'Income', isDark: isDark),
                const SizedBox(width: 12),
                _Legend(
                    color: AppColors.expense, label: 'Expense', isDark: isDark),
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
                          return Text(
                            months[i].label,
                            style: TextStyle(fontSize: 10, color: labelColor),
                          );
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

// ── Expense donut chart ──────────────────────────────────────────────────────

class _ExpenseDonutChart extends StatelessWidget {
  final StatisticsController ctrl;
  final double hPad;
  final bool isDark;
  const _ExpenseDonutChart(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    final cats = ctrl.topCategories;
    final total = cats.fold(0.0, (s, c) => s + c.amount);
    if (total == 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense by Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.grey900,
              ),
            ),
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
                            fontWeight: FontWeight.w600,
                          ),
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
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ca.category?.name ?? 'Other',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white : AppColors.grey900,
                                ),
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

// ── Top spending ─────────────────────────────────────────────────────────────

class _TopCategoriesList extends StatelessWidget {
  final StatisticsController ctrl;
  final double hPad;
  final bool isDark;
  const _TopCategoriesList(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    final cats = ctrl.topCategories;
    final maxAmt = cats.isEmpty ? 1.0 : cats.first.amount;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Spending',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.grey900,
              ),
            ),
            const SizedBox(height: 12),
            ...cats.map((ca) {
              final color = ctrl.categoryColor(ca);
              final pct = maxAmt > 0 ? ca.amount / maxAmt : 0.0;
              return GestureDetector(
                onTap: () => Get.to(
                  () => const CategoryDetailPage(),
                  arguments: ca,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              ca.category?.name ?? 'Uncategorized',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : AppColors.grey900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _fmt(ca.amount),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right_rounded,
                                  size: 16,
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : AppColors.grey400),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct.toDouble(),
                          minHeight: 6,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.grey200,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
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
  final bool isDark;
  const _Legend({required this.color, required this.label, required this.isDark});

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
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color:
                isDark ? Colors.white.withValues(alpha: 0.55) : AppColors.grey500,
          ),
        ),
      ],
    );
  }
}
