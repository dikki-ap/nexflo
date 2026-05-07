import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/adjust_balance_sheet.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/animated_amount.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/nexflo_button.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../services/currency_service.dart';

class WalletDetailPage extends StatelessWidget {
  const WalletDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Get.arguments as WalletEntity;
    final walletId = wallet.id;
    final ctrl = Get.find<WalletController>();
    final color = ColorHelper.fromHex(wallet.colorHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                wallet.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.65)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: -20,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      IconMapper.get(wallet.iconName),
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () {
                  Get.find<WalletController>().prepareForm(wallet);
                  Get.toNamed(
                    AppRoutes.walletEdit.replaceFirst(':id', wallet.id),
                    arguments: wallet,
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance highlight
                  GlassCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Balance',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppColors.grey500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Obx(() {
                              final w = ctrl.wallets.firstWhereOrNull((x) => x.id == walletId) ?? wallet;
                              return AnimatedAmount(
                                amount: w.balance,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  color: w.balance >= 0
                                      ? AppColors.income
                                      : AppColors.expense,
                                ),
                              );
                            }),
                          ],
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            IconMapper.get(wallet.iconName),
                            color: color,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info rows
                  GlassCard(
                    borderRadius: 20,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _InfoRow(
                          label: 'Type',
                          value: wallet.type.label,
                          isDark: isDark,
                          isFirst: true,
                        ),
                        _InfoRow(
                          label: 'Currency',
                          value: Get.find<CurrencyService>().baseCurrency,
                          isDark: isDark,
                        ),
                        if (wallet.creditLimit != null)
                          _InfoRow(
                            label: 'Credit Limit',
                            value:
                                '${Get.find<CurrencyService>().currencySymbol} ${wallet.creditLimit!.toStringAsFixed(2)}',
                            isDark: isDark,
                          ),
                        _InfoRow(
                          label: 'Excluded from Net Worth',
                          value: wallet.isExcludeTotal ? 'Yes' : 'No',
                          isDark: isDark,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  NexFloButton(
                    label: 'Adjust Balance',
                    icon: Icons.tune_rounded,
                    width: double.infinity,
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AdjustBalanceSheet(wallet: wallet),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isFirst;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.55)
                      : AppColors.grey500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.grey900,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark ? AppColors.glassBorder : AppColors.grey200,
          ),
      ],
    );
  }
}
