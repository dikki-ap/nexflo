import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/filter_period.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../services/sync_service.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: controller.loadAll,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _PeriodFilterChips(controller),
              const SizedBox(height: 16),
              _HeroSection(controller),
              const SizedBox(height: 20),
              _WalletsSection(controller),
              const SizedBox(height: 20),
              _PlanningSection(),
              const SizedBox(height: 20),
              _RecentTransactionsSection(controller),
              const SizedBox(height: 80),
            ],
          );
        }),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final user = controller.currentUser;
    return AppBar(
      title: Text(
        user != null ? 'Hello, ${user.name.split(' ').first}' : 'Hello',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      actions: [
        Obx(() {
          final sync = Get.find<SyncService>();
          return IconButton(
            icon: sync.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync),
            onPressed: () => sync.sync(),
            tooltip: 'Sync',
          );
        }),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _PeriodFilterChips extends StatelessWidget {
  final DashboardController ctrl;
  const _PeriodFilterChips(this.ctrl);

  static const _periods = [
    FilterPeriod.thisMonth,
    FilterPeriod.oneMonth,
    FilterPeriod.threeMonths,
    FilterPeriod.sixMonths,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _periods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final p = _periods[i];
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

class _HeroSection extends StatelessWidget {
  final DashboardController ctrl;
  const _HeroSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withValues(alpha: 0.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -12,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 48,
            bottom: -40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Net Worth',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Obx(() => Text(
                    _fmt(ctrl.netWorth),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() => Row(
                    children: [
                      _HeroStat(
                        label: 'Income',
                        amount: ctrl.totalIncome.value,
                        icon: Icons.arrow_upward_rounded,
                      ),
                      const SizedBox(width: 28),
                      _HeroStat(
                        label: 'Expense',
                        amount: ctrl.totalExpense.value,
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  const _HeroStat({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            Text(
              _fmt(amount),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _PlanningSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Planning',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          children: const [
            _PlanningCard(
              icon: Icons.pie_chart_outline,
              label: 'Budgets',
              color: AppColors.blue,
              route: AppRoutes.budgets,
            ),
            _PlanningCard(
              icon: Icons.flag_outlined,
              label: 'Goals',
              color: AppColors.green,
              route: AppRoutes.goals,
            ),
            _PlanningCard(
              icon: Icons.handshake_outlined,
              label: 'Debts',
              color: AppColors.orange,
              route: AppRoutes.debts,
            ),
            _PlanningCard(
              icon: Icons.repeat_outlined,
              label: 'Recurring',
              color: AppColors.teal,
              route: AppRoutes.recurring,
            ),
          ],
        ),
      ],
    );
  }
}

class _PlanningCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  const _PlanningCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _WalletsSection extends StatelessWidget {
  final DashboardController ctrl;
  const _WalletsSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Wallets',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.wallets),
              child: const Text('See All'),
            ),
          ],
        ),
        Obx(() {
          if (ctrl.wallets.isEmpty) {
            return GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.walletAdd),
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '+ Add your first wallet',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            );
          }
          return SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: ctrl.wallets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final w = ctrl.wallets[i];
                final color = ColorHelper.fromHex(w.colorHex);
                return GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.walletDetail.replaceFirst(':id', w.id),
                    arguments: w,
                  ),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(IconMapper.get(w.iconName),
                            color: Colors.white, size: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.name,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12)),
                            Text(
                              '${w.currencyCode} ${_fmtBalance(w.balance)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  String _fmtBalance(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  final DashboardController ctrl;
  const _RecentTransactionsSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.transactions),
              child: const Text('See All'),
            ),
          ],
        ),
        Obx(() {
          if (ctrl.recentTransactions.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4)),
                ),
              ),
            );
          }
          return Column(
            children: ctrl.recentTransactions.map((tx) {
              return _TxRow(tx, ctrl);
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  final TransactionEntity tx;
  final DashboardController ctrl;
  const _TxRow(this.tx, this.ctrl);

  @override
  Widget build(BuildContext context) {
    final cat = ctrl.categoryById(tx.categoryId);
    final wallet = ctrl.walletById(tx.walletId);
    final isExpense = tx.type == TransactionType.expense;
    final isTransfer = tx.type == TransactionType.transfer;
    final color = isTransfer
        ? AppColors.transfer
        : isExpense
            ? AppColors.expense
            : AppColors.income;
    final sign = isExpense ? '-' : isTransfer ? '' : '+';
    final catColor =
        cat != null ? ColorHelper.fromHex(cat.colorHex) : Colors.grey;

    return ListTile(
      onTap: () => Get.toNamed(
        AppRoutes.transactionDetail.replaceFirst(':id', tx.id),
        arguments: tx,
      ),
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: catColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
            cat != null ? IconMapper.get(cat.iconName) : Icons.swap_horiz,
            color: catColor,
            size: 18),
      ),
      title: Text(cat?.name ?? (isTransfer ? 'Transfer' : 'Uncategorized'),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(wallet?.name ?? '',
          style: const TextStyle(fontSize: 11)),
      trailing: Text(
        '$sign${_fmt(tx.amount)}',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 14, color: color),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
