import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../controllers/budget_controller.dart';

class BudgetDetailPage extends GetView<BudgetController> {
  const BudgetDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final budget = Get.arguments as BudgetEntity;
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(budget.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _BudgetHeader(budget: budget, ctrl: controller, hPad: hPad),
          const SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Row(
              children: [
                Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.grey500,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              final grouped = _groupByWeek(controller.detailTransactions);
              if (grouped.isEmpty) {
                return Center(
                  child: Text(
                    'No transactions this period',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : AppColors.grey400,
                    ),
                  ),
                );
              }
              final keys = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));
              return ListView.builder(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 100),
                itemCount: keys.length,
                itemBuilder: (_, i) {
                  final weekKey = keys[i];
                  final txs = grouped[weekKey]!;
                  final weekTotal =
                      txs.fold<double>(0, (s, t) => s + t.amount);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _weekLabel(weekKey),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white.withOpacity(0.5)
                                    : AppColors.grey500,
                              ),
                            ),
                            Text(
                              _fmt(weekTotal),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...txs.map((tx) => _TxTile(
                            tx: tx,
                            ctrl: controller,
                            isDark: isDark,
                          )),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<TransactionEntity>> _groupByWeek(
      List<TransactionEntity> txs) {
    final map = <DateTime, List<TransactionEntity>>{};
    for (final tx in txs) {
      final monday = tx.date.subtract(Duration(days: tx.date.weekday - 1));
      final key = DateTime(monday.year, monday.month, monday.day);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  String _weekLabel(DateTime monday) {
    final months = const [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return 'Week of ${monday.day} ${months[monday.month]}';
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _BudgetHeader extends StatelessWidget {
  final BudgetEntity budget;
  final BudgetController ctrl;
  final double hPad;
  const _BudgetHeader(
      {required this.budget, required this.ctrl, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final spent = ctrl.spentFor(budget);
    final limit = ctrl.effectiveLimitFor(budget);
    final progress = ctrl.progressFor(budget).clamp(0.0, 1.0);
    final progressColor = _progressColor(ctrl.progressFor(budget));

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
      child: GlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    budget.period.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                if (ctrl.progressFor(budget) > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Over Budget',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(
                      height: 10, color: progressColor.withOpacity(0.12)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          progressColor.withOpacity(0.75),
                          progressColor,
                        ]),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(spent),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: progressColor,
                  ),
                ),
                Text(
                  'of ${_fmt(limit)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withOpacity(0.45)
                        : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _progressColor(double p) {
    if (p > 1.0) return AppColors.budgetOver;
    if (p >= 0.8) return AppColors.budgetAlert;
    if (p >= 0.6) return AppColors.budgetWarning;
    return AppColors.budgetSafe;
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _TxTile extends StatelessWidget {
  final TransactionEntity tx;
  final BudgetController ctrl;
  final bool isDark;
  const _TxTile({required this.tx, required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cat = ctrl.categoryById(tx.categoryId);
    final wallet = ctrl.walletById(tx.walletId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.expense.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: AppColors.expense, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.note ?? cat?.name ?? 'Expense',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_dateLabel(tx.date)}${wallet != null ? ' · ${wallet.name}' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${_fmt(tx.amount)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.expense,
              ),
            ),
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

  String _dateLabel(DateTime d) {
    final months = const [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]}';
  }
}
