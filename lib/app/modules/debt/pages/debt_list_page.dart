import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/debt_type.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/animated_amount.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/widgets/staggered_list.dart';
import '../../../domain/entities/debt_entity.dart';
import '../controllers/debt_controller.dart';
import '../../../services/currency_service.dart';

class DebtListPage extends GetView<DebtController> {
  const DebtListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Debts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerLoading(
            isLoading: true,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12),
                  child: Row(
                    children: [
                      Expanded(
                          child: ShimmerCard(
                              height: 80, horizontalMargin: 0, borderRadius: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: ShimmerCard(
                              height: 80, horizontalMargin: 0, borderRadius: 18)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    itemCount: 5,
                    itemBuilder: (_, __) => const ShimmerCard(
                      height: 76,
                      horizontalMargin: 0,
                      borderRadius: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (controller.debts.isEmpty) {
          return _EmptyState();
        }
        int staggerIdx = 0;
        return ListView(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 100),
          children: [
            _SummaryBanner(controller, isDark),
            const SizedBox(height: 20),
            if (controller.iOweList.isNotEmpty) ...[
              SectionLabel(
                label: 'I Owe',
                padding: const EdgeInsets.only(bottom: 10),
              ),
              ...controller.iOweList.map((d) {
                final w = StaggeredItem(
                  delayIndex: staggerIdx,
                  child: _DebtCard(d, isDark),
                );
                staggerIdx++;
                return w;
              }),
            ],
            if (controller.owedToMeList.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionLabel(
                label: 'Owed to Me',
                padding: const EdgeInsets.only(bottom: 10),
              ),
              ...controller.owedToMeList.map((d) {
                final w = StaggeredItem(
                  delayIndex: staggerIdx,
                  child: _DebtCard(d, isDark),
                );
                staggerIdx++;
                return w;
              }),
            ],
          ],
        );
      }),
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          controller.initForm();
          Get.toNamed(AppRoutes.debtAdd);
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 22),
              SizedBox(width: 6),
              Text(
                'Add Debt',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final DebtController ctrl;
  final bool isDark;
  const _SummaryBanner(this.ctrl, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'I Owe',
                amount: ctrl.totalIOwe,
                color: AppColors.expense,
                icon: Icons.arrow_upward_rounded,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryTile(
                label: 'Owed to Me',
                amount: ctrl.totalOwedToMe,
                color: AppColors.income,
                icon: Icons.arrow_downward_rounded,
                isDark: isDark,
              ),
            ),
          ],
        ));
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isDark;
  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.55)
                      : AppColors.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedAmount(
            amount: amount,
            style: TextStyle(
              fontSize: 20,
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.handshake_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No debts recorded',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.grey900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to track a debt',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : AppColors.grey400,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  final DebtEntity debt;
  final bool isDark;
  const _DebtCard(this.debt, this.isDark);

  @override
  Widget build(BuildContext context) {
    final isIOwe = debt.type == DebtType.iOwe;
    final color = isIOwe ? AppColors.expense : AppColors.income;

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      onTap: () => Get.toNamed(
        AppRoutes.debtDetail.replaceFirst(':id', debt.id),
        arguments: debt,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIOwe
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.personName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${Get.find<CurrencyService>().currencySymbol} ${_fmt(debt.remaining)} remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.45)
                            : AppColors.grey500,
                      ),
                    ),
                    if (debt.isOverdue) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Overdue',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            _fmt(debt.remaining),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
