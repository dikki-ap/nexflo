import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_animations.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/filter_period.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/animated_amount.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/staggered_list.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../services/sync_service.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: RefreshIndicator(
        onRefresh: controller.loadAll,
        color: Theme.of(context).colorScheme.primary,
        displacement: 60,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashHeader(controller, hPad, isDark),
                const SizedBox(height: 16),
                _PeriodTabs(controller, hPad, isDark),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.isLoading.value) {
                    return ShimmerLoading(
                      isLoading: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerCard(height: 148, horizontalMargin: hPad),
                          const SizedBox(height: 24),
                          ShimmerWalletRow(height: 155),
                          const SizedBox(height: 24),
                          ShimmerCard(height: 120, horizontalMargin: hPad),
                          const SizedBox(height: 24),
                          ...List.generate(
                            5,
                            (_) => ShimmerListTile(horizontalPadding: hPad),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: _HeroCard(controller),
                      ),
                      const SizedBox(height: 24),
                      _WalletsSection(controller, hPad, isDark),
                      const SizedBox(height: 24),
                      _PlanningSection(hPad, isDark),
                      const SizedBox(height: 24),
                      _RecentSection(controller, hPad, isDark),
                    ],
                  );
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _DashHeader extends StatelessWidget {
  final DashboardController ctrl;
  final double hPad;
  final bool isDark;
  const _DashHeader(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    final firstName = ctrl.currentUser?.name.split(' ').first ?? 'there';
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $firstName',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.grey900,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Your financial overview',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.45)
                        : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final sync = Get.find<SyncService>();
            return GestureDetector(
              onTap: () => sync.sync(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.glassBorder : AppColors.grey200,
                    width: 1,
                  ),
                ),
                child: sync.isSyncing
                    ? Padding(
                        padding: const EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.sync_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Period Tabs ──────────────────────────────────────────────────────────────

class _PeriodTabs extends StatelessWidget {
  final DashboardController ctrl;
  final double hPad;
  final bool isDark;

  static const _periods = [
    FilterPeriod.thisMonth,
    FilterPeriod.oneMonth,
    FilterPeriod.threeMonths,
    FilterPeriod.sixMonths,
  ];

  const _PeriodTabs(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Obx(() {
        final selected = ctrl.selectedPeriod.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          itemCount: _periods.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final p = _periods[i];
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
                          color: isDark
                              ? AppColors.grey700
                              : AppColors.grey200,
                          width: 1,
                        ),
                ),
                child: Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
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

// ── Hero Card ────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final DashboardController ctrl;
  const _HeroCard(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient(Theme.of(context).colorScheme.primary),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8,
            top: -24,
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
            right: 44,
            bottom: -32,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NET WORTH',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Obx(() => AnimatedAmount(
                    amount: ctrl.netWorth,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  )),
              const SizedBox(height: 20),
              Obx(() => Row(
                    children: [
                      _HeroStat(
                        label: 'Income',
                        amount: ctrl.totalIncome.value,
                        icon: Icons.arrow_upward_rounded,
                        iconBg: AppColors.income,
                      ),
                      const SizedBox(width: 32),
                      _HeroStat(
                        label: 'Expense',
                        amount: ctrl.totalExpense.value,
                        icon: Icons.arrow_downward_rounded,
                        iconBg: AppColors.expense,
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconBg;

  const _HeroStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconBg.withValues(alpha: 0.25),
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
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 11,
              ),
            ),
            AnimatedAmount(
              amount: amount,
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
}

// ── Wallets ──────────────────────────────────────────────────────────────────

class _WalletsSection extends StatelessWidget {
  final DashboardController ctrl;
  final double hPad;
  final bool isDark;
  const _WalletsSection(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: SectionLabel(
            label: 'Wallets',
            onSeeAll: () => Get.toNamed(AppRoutes.wallets),
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (ctrl.wallets.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: GlassCard(
                onTap: () => Get.toNamed(AppRoutes.walletAdd),
                borderRadius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Add your first wallet',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final cardWidth =
              (MediaQuery.of(context).size.width * 0.42).clamp(130.0, 200.0);

          return SizedBox(
            height: 155,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: hPad),
              itemCount: ctrl.wallets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final w = ctrl.wallets[i];
                final color = ColorHelper.fromHex(w.colorHex);
                return GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.walletDetail.replaceFirst(':id', w.id),
                    arguments: w,
                  ),
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.28),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                IconMapper.get(w.iconName),
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white.withValues(alpha: 0.45),
                              size: 11,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              w.name,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            AnimatedAmount(
                              amount: w.balance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                letterSpacing: -0.3,
                              ),
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
}

// ── Planning ─────────────────────────────────────────────────────────────────

class _PlanItem {
  final IconData icon;
  final String label;
  final Color? color;
  final String route;
  const _PlanItem({
    required this.icon,
    required this.label,
    this.color,
    required this.route,
  });
}

class _PlanningSection extends StatelessWidget {
  final double hPad;
  final bool isDark;
  const _PlanningSection(this.hPad, this.isDark);

  static final _items = [
    _PlanItem(
      icon: Icons.pie_chart_outline,
      label: 'Budgets',
      color: AppColors.blue,
      route: AppRoutes.budgets,
    ),
    _PlanItem(
      icon: Icons.flag_outlined,
      label: 'Goals',
      color: AppColors.green,
      route: AppRoutes.goals,
    ),
    _PlanItem(
      icon: Icons.handshake_outlined,
      label: 'Debts',
      color: AppColors.orange,
      route: AppRoutes.debts,
    ),
    _PlanItem(
      icon: Icons.repeat_rounded,
      label: 'Recurring',
      route: AppRoutes.recurring,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final crossCount = context.planningGridCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: const SectionLabel(label: 'Planning'),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: GridView.count(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.55,
            children: _items
                .map((item) => _PlanningCard(item: item, isDark: isDark))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _PlanningCard extends StatelessWidget {
  final _PlanItem item;
  final bool isDark;
  const _PlanningCard({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = item.color ?? Theme.of(context).colorScheme.primary;
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      color: color.withValues(alpha: isDark ? 0.12 : 0.07),
      onTap: () {
        HapticFeedback.lightImpact();
        Get.toNamed(item.route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: color, size: 20),
          ),
          const SizedBox(height: 7),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent Transactions ──────────────────────────────────────────────────────

class _RecentSection extends StatelessWidget {
  final DashboardController ctrl;
  final double hPad;
  final bool isDark;
  const _RecentSection(this.ctrl, this.hPad, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: SectionLabel(
            label: 'Recent Transactions',
            onSeeAll: () => Get.toNamed(AppRoutes.transactions),
          ),
        ),
        const SizedBox(height: 14),
        Obx(() {
          if (ctrl.recentTransactions.isEmpty) {
            return Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              child: Center(
                child: Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.35)
                        : AppColors.grey400,
                  ),
                ),
              ),
            );
          }
          return Column(
            children: List.generate(
              ctrl.recentTransactions.length,
              (i) => StaggeredItem(
                delayIndex: i,
                child: _TxTile(
                  tx: ctrl.recentTransactions[i],
                  ctrl: ctrl,
                  isDark: isDark,
                  hPad: hPad,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TxTile extends StatelessWidget {
  final TransactionEntity tx;
  final DashboardController ctrl;
  final bool isDark;
  final double hPad;

  const _TxTile({
    required this.tx,
    required this.ctrl,
    required this.isDark,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    final cat = ctrl.categoryById(tx.categoryId);
    final wallet = ctrl.walletById(tx.walletId);
    final isExpense = tx.type == TransactionType.expense;
    final isTransfer = tx.type == TransactionType.transfer;
    final amountColor = isTransfer
        ? AppColors.transfer
        : isExpense
            ? AppColors.expense
            : AppColors.income;
    final sign = isExpense ? '-' : isTransfer ? '' : '+';
    final catColor =
        cat != null ? ColorHelper.fromHex(cat.colorHex) : AppColors.grey400;

    return Padding(
      padding: EdgeInsets.only(left: hPad, right: hPad, bottom: 8),
      child: GlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: () => Get.toNamed(
          AppRoutes.transactionDetail.replaceFirst(':id', tx.id),
          arguments: tx,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                cat != null
                    ? IconMapper.get(cat.iconName)
                    : Icons.swap_horiz_rounded,
                color: catColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat?.name ??
                        (isTransfer ? 'Transfer' : 'Uncategorized'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    wallet?.name ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.grey400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$sign${_fmt(tx.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    final absStr = NumberFormat('#,##0').format(v.abs());
    return v < 0 ? '-$absStr' : absStr;
  }
}
