import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/wallet_card.dart';
import '../widgets/adjust_balance_sheet.dart';
import '../../../config/routes/app_routes.dart';

class WalletListPage extends GetView<WalletController> {
  const WalletListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              controller.prepareForm();
              Get.toNamed(AppRoutes.walletAdd);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.wallets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text('No wallets yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('Tap + to add your first wallet',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5))),
              ],
            ),
          );
        }
        return Column(
          children: [
            _NetWorthBanner(controller),
            Expanded(
              child: ReorderableListView.builder(
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.prepareForm();
          Get.toNamed(AppRoutes.walletAdd);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Wallet'),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
  const _NetWorthBanner(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final nw = ctrl.totalNetWorth;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Net Worth',
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 14)),
            Text(
              _fmt(nw),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    });
  }

  String _fmt(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    return v.toStringAsFixed(0);
  }
}
