import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/debt_type.dart';
import '../../../domain/entities/debt_entity.dart';
import '../../../domain/entities/debt_payment_entity.dart';
import '../controllers/debt_controller.dart';
import '../../../services/currency_service.dart';

class DebtDetailPage extends GetView<DebtController> {
  const DebtDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final debt = Get.arguments as DebtEntity;
    final isIOwe = debt.type == DebtType.iOwe;
    final color = isIOwe ? AppColors.expense : AppColors.income;
    final progress =
        debt.amount > 0 ? (debt.paidAmount / debt.amount).clamp(0.0, 1.0) : 0.0;

    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.loadPayments(debt.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(debt.personName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              controller.initForm(debt);
              Get.toNamed(AppRoutes.debtAdd, arguments: debt);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, debt),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(debt.type.label,
                            style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      if (debt.isOverdue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.expense.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Overdue',
                              style: TextStyle(
                                  color: AppColors.expense,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${Get.find<CurrencyService>().currencySymbol} ${_fmt(debt.remaining)}',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                  Text('remaining of ${_fmt(debt.amount)}',
                      style: TextStyle(
                          fontSize: 13,
                          color: color.withValues(alpha: 0.7))),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: color.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% paid',
                    style: TextStyle(
                        fontSize: 12, color: color.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow('Total Amount',
                        '${Get.find<CurrencyService>().currencySymbol} ${_fmt(debt.amount)}'),
                    _InfoRow('Paid',
                        '${Get.find<CurrencyService>().currencySymbol} ${_fmt(debt.paidAmount)}',
                        valueColor: AppColors.income),
                    _InfoRow('Status', _statusLabel(debt.status.value)),
                    if (debt.deadline != null)
                      _InfoRow('Deadline', _fmtDate(debt.deadline!)),
                    if (debt.note != null && debt.note!.isNotEmpty)
                      _InfoRow('Note', debt.note!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (debt.remaining > 0)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showPaymentSheet(context, debt),
                  icon: const Icon(Icons.payment),
                  label: const Text('Record Payment'),
                ),
              ),
            const SizedBox(height: 20),
            // Payment history
            const Text('Payment History',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.payments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('No payments recorded',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4))),
                  ),
                );
              }
              return Column(
                children: controller.payments
                    .map((p) => _PaymentTile(p, color))
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context, DebtEntity debt) {
    controller.paymentAmountCtrl.clear();
    controller.paymentNoteCtrl.clear();
    controller.selectedPaymentWalletId.value = null;
    final sym = Get.find<CurrencyService>().currencySymbol;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Record Payment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            // Wallet selector
            Obx(() {
              final wallets = controller.wallets;
              if (wallets.isEmpty) {
                return const Text('No wallets available',
                    style: TextStyle(color: Colors.grey));
              }
              return DropdownButtonFormField<String>(
                value: controller.selectedPaymentWalletId.value,
                decoration: InputDecoration(
                  labelText: debt.type == DebtType.iOwe
                      ? 'Pay from wallet'
                      : 'Receive to wallet',
                  border: const OutlineInputBorder(),
                  prefixIcon:
                      const Icon(Icons.account_balance_wallet_outlined),
                ),
                items: wallets.map((w) {
                  return DropdownMenuItem(
                    value: w.id,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(w.name),
                        Text(
                          '$sym ${_fmt(w.balance)}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) =>
                    controller.selectedPaymentWalletId.value = v,
              );
            }),
            // Available balance hint
            Obx(() {
              final wallet = controller.selectedPaymentWallet;
              if (wallet == null) return const SizedBox(height: 12);
              return Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Text(
                  'Available: $sym ${_fmt(wallet.balance)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              );
            }),
            const SizedBox(height: 12),
            TextField(
              controller: controller.paymentAmountCtrl,
              autofocus: false,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount (max ${_fmt(debt.remaining)})',
                prefixText: '$sym ',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.paymentNoteCtrl,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => controller.recordPayment(debt),
                child: const Text('Record'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, DebtEntity debt) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Debt'),
        content: Text('Delete debt with ${debt.personName}?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteDebt(debt.id);
              Get.back();
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String status) => switch (status) {
        'active' => 'Active',
        'partially_paid' => 'Partially Paid',
        'settled' => 'Settled',
        _ => status,
      };

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  String _fmtDate(DateTime d) =>
      '${d.day} ${_month(d.month)} ${d.year}';

  String _month(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];
}

class _PaymentTile extends StatelessWidget {
  final DebtPaymentEntity payment;
  final Color color;
  const _PaymentTile(this.payment, this.color);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.income.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.check, color: AppColors.income, size: 18),
      ),
      title: Text(_fmt(payment.amount),
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(payment.note ?? _fmtDate(payment.date),
          style: const TextStyle(fontSize: 12)),
      trailing: Text(_fmtDate(payment.date),
          style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.4))),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  String _fmtDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});

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
                      .withValues(alpha: 0.55),
                  fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: valueColor)),
        ],
      ),
    );
  }
}
