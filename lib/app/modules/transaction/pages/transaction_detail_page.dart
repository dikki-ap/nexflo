import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/transaction_type.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/transaction_entity.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = Get.arguments as TransactionEntity;
    final ctrl = Get.find<TransactionController>();
    final category = ctrl.categoryById(tx.categoryId);
    final wallet = ctrl.walletById(tx.walletId);

    final isExpense = tx.type == TransactionType.expense;
    final isTransfer = tx.type == TransactionType.transfer;
    final amountColor = isTransfer
        ? AppColors.transfer
        : isExpense
            ? AppColors.expense
            : AppColors.income;
    final sign = isExpense ? '-' : isTransfer ? '' : '+';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ctrl.prepareForm(tx);
              Get.toNamed(
                AppRoutes.transactionEdit.replaceFirst(':id', tx.id),
                arguments: tx,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ctrl, tx.id),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: amountColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  if (category != null)
                    Icon(
                      IconMapper.get(category.iconName),
                      size: 40,
                      color: ColorHelper.fromHex(category.colorHex),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    '$sign${wallet?.currencyCode ?? ''} ${_fmt(tx.amount)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  Text(
                    category?.name ?? tx.type.name,
                    style: TextStyle(
                        fontSize: 16,
                        color: amountColor.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  _Row('Type', tx.type.name.toUpperCase()),
                  _Row('Wallet', wallet?.name ?? tx.walletId),
                  _Row('Date', _formatDate(tx.date)),
                  if (tx.note != null && tx.note!.isNotEmpty)
                    _Row('Note', tx.note!),
                  if (isTransfer && tx.toWalletId != null)
                    _Row('To Wallet',
                        ctrl.walletById(tx.toWalletId)?.name ?? tx.toWalletId!),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, TransactionController ctrl, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Get.back();
              ctrl.deleteTransaction(id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    return v.toStringAsFixed(2);
  }

  String _formatDate(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

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
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style:
                      const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
