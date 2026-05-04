import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transaction_filter_bar.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class TransactionListPage extends GetView<TransactionController> {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const TransactionFilterBar(),
          _SummaryRow(),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.transactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text('No transactions',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Text('Tap + to record a transaction',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5))),
                    ],
                  ),
                );
              }
              final grouped = controller.grouped;
              final keys = grouped.keys.toList();
              return ListView.builder(
                itemCount: keys.length,
                itemBuilder: (_, i) {
                  final key = keys[i];
                  final txs = grouped[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateHeader(key, txs),
                      ...txs.map((tx) => TransactionTile(
                            tx: tx,
                            category: controller.categoryById(tx.categoryId),
                            wallet: controller.walletById(tx.walletId),
                            onTap: () => Get.toNamed(
                              AppRoutes.transactionDetail
                                  .replaceFirst(':id', tx.id),
                              arguments: tx,
                            ),
                            onDelete: () =>
                                controller.deleteTransaction(tx.id),
                          )),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.prepareForm();
          Get.toNamed(AppRoutes.transactionAdd);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _TxSearchDelegate(controller),
    );
  }
}

class _SummaryRow extends GetView<TransactionController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: _SummaryChip(
                  label: 'Income',
                  amount: controller.totalIncome.value,
                  color: AppColors.income,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(
                  label: 'Expense',
                  amount: controller.totalExpense.value,
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
        ));
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color.withValues(alpha: 0.8))),
          Text(
            _fmt(amount),
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 16),
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

class _DateHeader extends StatelessWidget {
  final String date;
  final List txs;
  const _DateHeader(this.date, this.txs);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        date,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

class _TxSearchDelegate extends SearchDelegate {
  final TransactionController ctrl;
  _TxSearchDelegate(this.ctrl);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) =>
      IconButton(icon: const Icon(Icons.arrow_back), onPressed: close);

  @override
  Widget buildResults(BuildContext context) {
    ctrl.setSearch(query);
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) ctrl.setSearch(query);
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    return Obx(() => ListView(
          children: ctrl.transactions
              .map((tx) => TransactionTile(
                    tx: tx,
                    category: ctrl.categoryById(tx.categoryId),
                    wallet: ctrl.walletById(tx.walletId),
                  ))
              .toList(),
        ));
  }

  void close(BuildContext context) {
    ctrl.setSearch('');
    super.close(context, null);
  }
}
