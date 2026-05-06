import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/wallet_card.dart';
import '../widgets/adjust_balance_sheet.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/animated_amount.dart';
import '../../../core/widgets/shimmer_loading.dart';

class WalletListPage extends GetView<WalletController> {
  const WalletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              controller.prepareForm();
              Get.toNamed(AppRoutes.walletAdd);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerLoading(
            isLoading: true,
            child: Column(
              children: [
                ShimmerCard(height: 72, horizontalMargin: context.horizontalPadding),
                const SizedBox(height: 8),
                ...List.generate(
                  5,
                  (_) => ShimmerCard(
                    height: 80,
                    horizontalMargin: context.horizontalPadding,
                    borderRadius: 16,
                  ),
                ),
              ],
            ),
          );
        }
        if (controller.wallets.isEmpty) {
          return _EmptyState();
        }
        return Column(
          children: [
            _NetWorthBanner(controller, isDark: isDark),
            Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: controller.wallets.length,
                onReorder: controller.reorder,
                itemBuilder: (_, i) {
                  final w = controller.wallets[i];
                  return WalletCard(
                    key: ValueKey(w.id),
                    wallet: w,
                    onTap: () => Get.toNamed(
                      AppRoutes.walletDetail.replaceFirst(':id', w.id),
                      arguments: w,
                    ),
                    onEdit: () {
                      controller.prepareForm(w);
                      Get.toNamed(
                        AppRoutes.walletEdit.replaceFirst(':id', w.id),
                        arguments: w,
                      );
                    },
                    onDelete: () => _confirmDelete(context, w.id, w.name),
                  );
                },
              ),
            ),
          ],
        );
      }),
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          controller.prepareForm();
          Get.toNamed(AppRoutes.walletAdd);
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.tealGlow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add_rounded, color: Colors.white, size: 22),
              SizedBox(width: 6),
              Text(
                'Add Wallet',
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

  void _confirmDelete(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Wallet'),
        content: Text('Delete "$name"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () {
              Get.back();
              controller.deleteWallet(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _NetWorthBanner extends StatelessWidget {
  final WalletController ctrl;
  final bool isDark;
  const _NetWorthBanner(this.ctrl, {required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hPad = context.horizontalPadding;
    return Obx(() => Container(
          margin: EdgeInsets.fromLTRB(hPad, 12, hPad, 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.tealGlow,
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Worth',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AnimatedAmount(
                amount: ctrl.totalNetWorth,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ));
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
            decoration: const BoxDecoration(
              color: AppColors.tealGlowSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 36,
              color: AppColors.tealMid,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No wallets yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.grey900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first wallet',
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
