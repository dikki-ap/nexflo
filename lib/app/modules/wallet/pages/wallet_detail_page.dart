import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/adjust_balance_sheet.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/wallet_entity.dart';

class WalletDetailPage extends StatelessWidget {
  const WalletDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = Get.arguments as WalletEntity;
    final color = ColorHelper.fromHex(wallet.colorHex);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(wallet.name,
                  style: const TextStyle(color: Colors.white)),
              background: Container(
                color: color,
                child: Center(
                  child: Icon(
                    IconMapper.get(wallet.iconName),
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
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
                  _InfoCard(wallet),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.tune),
                      label: const Text('Adjust Balance'),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) =>
                            AdjustBalanceSheet(wallet: wallet),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Recent Transactions',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Transaction list coming in full Phase 2',
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4)),
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

class _InfoCard extends StatelessWidget {
  final WalletEntity wallet;
  const _InfoCard(this.wallet);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _Row('Type', wallet.type.label),
            _Row('Currency', wallet.currencyCode),
            _Row(
              'Balance',
              '${wallet.currencyCode} ${wallet.balance.toStringAsFixed(2)}',
              valueColor: wallet.balance >= 0
                  ? Colors.green
                  : Colors.red,
            ),
            if (wallet.creditLimit != null)
              _Row('Credit Limit',
                  '${wallet.currencyCode} ${wallet.creditLimit!.toStringAsFixed(2)}'),
            _Row('Exclude from Net Worth',
                wallet.isExcludeTotal ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Row(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6))),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}
