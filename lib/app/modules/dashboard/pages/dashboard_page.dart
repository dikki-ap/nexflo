import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/filter_period.dart';
import '../../../services/sync_service.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO(phase-2): refresh data
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            _PeriodFilterChips(controller),
            const SizedBox(height: 16),
            _NetWorthCard(controller),
            const SizedBox(height: 16),
            _IncomExpenseSummary(controller),
            const SizedBox(height: 16),
            _WalletsSection(),
            const SizedBox(height: 16),
            _RecentTransactionsSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final user = controller.currentUser;
    return AppBar(
      title: Text(
        user != null ? 'Hello, ${user.name.split(' ').first}' : 'Hello',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
      ),
      actions: [
        // Sync indicator
        Obx(() {
          final syncService = Get.find<SyncService>();
          return IconButton(
            icon: syncService.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            onPressed: () => syncService.sync(),
            tooltip: 'Sync',
          );
        }),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _PeriodFilterChips extends StatelessWidget {
  final DashboardController ctrl;
  const _PeriodFilterChips(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final periods = [
      FilterPeriod.thisMonth,
      FilterPeriod.oneMonth,
      FilterPeriod.threeMonths,
      FilterPeriod.sixMonths,
      FilterPeriod.custom,
    ];
    return SizedBox(
      height: 36,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: periods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final p = periods[i];
              final selected = ctrl.selectedPeriod.value == p;
              return FilterChip(
                label: Text(p.label,
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                selected: selected,
                onSelected: (_) => ctrl.changePeriod(p),
              );
            },
          )),
    );
  }
}

class _NetWorthCard extends StatelessWidget {
  final DashboardController ctrl;
  const _NetWorthCard(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Net Worth',
                style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6))),
            const SizedBox(height: 6),
            Obx(() => Text(
                  '\$${ctrl.netWorth.value.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold, color: accent),
                )),
          ],
        ),
      ),
    );
  }
}

class _IncomExpenseSummary extends StatelessWidget {
  final DashboardController ctrl;
  const _IncomExpenseSummary(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.arrow_upward, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text('Income',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6))),
                  ]),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        '\$${ctrl.totalIncome.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      )),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.arrow_downward, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    Text('Expense',
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6))),
                  ]),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        '\$${ctrl.totalExpense.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WalletsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Wallets',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () {
                // TODO(phase-2): navigate to wallet list
              },
              child: const Text('See All'),
            ),
          ],
        ),
        SizedBox(
          height: 120,
          child: Center(
            child: Text(
              'No wallets yet.\nTap + to add your first wallet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                  fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            TextButton(
              onPressed: () {
                // TODO(phase-2): navigate to transaction list
              },
              child: const Text('See All'),
            ),
          ],
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No transactions yet.\nAdd your first transaction!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.4),
                  fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
