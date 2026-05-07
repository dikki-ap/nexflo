import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/transaction_filter_bar.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/animated_amount.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_loading.dart';

class TransactionListPage extends GetView<TransactionController> {
  const TransactionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const TransactionFilterBar(),
          _SummaryRow(hPad: hPad, isDark: isDark),
          const SizedBox(height: 4),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return ShimmerLoading(
                  isLoading: true,
                  child: Column(
                    children: List.generate(
                      8,
                      (_) => ShimmerListTile(horizontalPadding: hPad),
                    ),
                  ),
                );
              }
              if (controller.transactions.isEmpty) {
                return _EmptyState();
              }
              final grouped = controller.grouped;
              final keys = grouped.keys.toList();
              return ListView.builder(
                padding: EdgeInsets.only(bottom: 100, top: 4),
                itemCount: keys.length,
                itemBuilder: (_, i) {
                  final key = keys[i];
                  final txs = grouped[key]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateHeader(date: key, isDark: isDark, hPad: hPad),
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
      floatingActionButton: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          controller.prepareForm();
          Get.toNamed(AppRoutes.transactionAdd);
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.tealGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.tealGlow,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
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
  final double hPad;
  final bool isDark;
  const _SummaryRow({required this.hPad, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
          child: Row(
            children: [
              Expanded(
                child: GlassCard(
                  borderRadius: 14,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: AppColors.income.withValues(alpha: 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.income.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedAmount(
                        amount: controller.totalIncome.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.income,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  borderRadius: 14,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  color: AppColors.expense.withValues(alpha: 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expense',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.expense.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedAmount(
                        amount: controller.totalExpense.value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  final bool isDark;
  final double hPad;
  const _DateHeader({required this.date, required this.isDark, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 6),
      child: Text(
        date.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark
              ? Colors.white.withValues(alpha: 0.4)
              : AppColors.grey400,
        ),
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
              color: AppColors.tealGlowSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: AppColors.tealMid,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No transactions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.grey900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to record a transaction',
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

class _TxSearchDelegate extends SearchDelegate {
  final TransactionController ctrl;
  _TxSearchDelegate(this.ctrl);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) {
    ctrl.setSearch(query);
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    ctrl.setSearch(query);
    return _buildList();
  }

  Widget _buildList() {
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

  void close(BuildContext context, dynamic result) {
    ctrl.setSearch('');
    super.close(context, result);
  }
}
