import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/goal_status.dart';
import '../../../core/utils/color_helper.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/goal_entity.dart';
import '../../../services/currency_service.dart';
import '../controllers/goal_controller.dart';

class GoalDetailPage extends GetView<GoalController> {
  const GoalDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final goal = Get.arguments as GoalEntity;
    final color = ColorHelper.fromHex(goal.colorHex);
    final isDone = goal.status == GoalStatus.completed;
    final onTrack = controller.onTrackLabel(goal);
    final projected = controller.projectedCompletion(goal);
    final sym = Get.find<CurrencyService>().currencySymbol;

    // Load allocation history when page opens
    controller.loadAllocationHistory(goal);

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              controller.initForm(goal);
              Get.toNamed(AppRoutes.goalAdd, arguments: goal);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, goal),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Hero progress circle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Icon(IconMapper.get(goal.iconName),
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$sym ${_fmt(goal.currentAmount)} / $sym ${_fmt(goal.targetAmount)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: goal.progress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(goal.progress * 100).toStringAsFixed(1)}% reached',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _GoalProgressChart(goal: goal, color: color),
            const SizedBox(height: 16),
            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow('Status', isDone ? 'Completed' : 'Active'),
                    if (onTrack.isNotEmpty)
                      _InfoRow('Progress', onTrack,
                          valueColor: onTrack == 'On Track'
                              ? AppColors.income
                              : AppColors.budgetAlert),
                    if (goal.daysRemaining != null)
                      _InfoRow(
                        'Deadline',
                        goal.daysRemaining! >= 0
                            ? '${goal.daysRemaining} days left'
                            : 'Overdue',
                        valueColor: goal.daysRemaining! < 0
                            ? AppColors.expense
                            : null,
                      ),
                    if (projected != null)
                      _InfoRow('Projected Completion', _fmtDate(projected)),
                    if (goal.note != null && goal.note!.isNotEmpty)
                      _InfoRow('Note', goal.note!),
                  ],
                ),
              ),
            ),
            if (!isDone) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _showAllocateSheet(context, goal),
                  icon: const Icon(Icons.add),
                  label: const Text('Allocate Funds'),
                ),
              ),
            ],
            // Allocation history
            Obx(() {
              final history = controller.allocationHistory;
              if (history.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'ALLOCATION HISTORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: history.map((tx) {
                        return ListTile(
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.savings_outlined,
                                color: color, size: 18),
                          ),
                          title: Text(
                            _fmtDate(tx.date),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            '+ $sym ${_fmt(tx.amount)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAllocateSheet(BuildContext context, GoalEntity goal) {
    controller.allocateCtrl.clear();
    controller.selectedAllocateWalletId.value = null;
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
            const Text('Allocate Funds',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            // Wallet selector
            Obx(() {
              final wallets = controller.wallets;
              if (wallets.isEmpty) {
                return const Text('No wallets available',
                    style: TextStyle(color: Colors.grey));
              }
              final sym = Get.find<CurrencyService>().currencySymbol;
              return DropdownButtonFormField<String>(
                value: controller.selectedAllocateWalletId.value,
                decoration: const InputDecoration(
                  labelText: 'From wallet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
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
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) =>
                    controller.selectedAllocateWalletId.value = v,
              );
            }),
            // Available balance hint
            Obx(() {
              final wallet = controller.selectedWallet;
              if (wallet == null) return const SizedBox(height: 12);
              final sym = Get.find<CurrencyService>().currencySymbol;
              return Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                child: Text(
                  'Available: $sym ${_fmt(wallet.balance)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            TextField(
              controller: controller.allocateCtrl,
              autofocus: false,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Amount to allocate',
                prefixText:
                    '${Get.find<CurrencyService>().currencySymbol} ',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => controller.allocate(goal),
                child: const Text('Allocate'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, GoalEntity goal) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Delete "${goal.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deleteGoal(goal.id);
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

  String _fmt(double v) {
    final absStr = NumberFormat('#,##0').format(v.abs());
    return v < 0 ? '-$absStr' : absStr;
  }

  String _fmtDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

class _GoalProgressChart extends StatelessWidget {
  final GoalEntity goal;
  final Color color;
  const _GoalProgressChart({required this.goal, required this.color});

  @override
  Widget build(BuildContext context) {
    final daysElapsed = DateTime.now()
        .difference(goal.createdAt)
        .inDays
        .toDouble()
        .clamp(1.0, double.infinity);
    final currentPct = goal.progress * 100;

    final hasDeadline = goal.deadline != null;
    final totalDays = hasDeadline
        ? goal.deadline!.difference(goal.createdAt).inDays.toDouble()
        : null;
    final maxX = (totalDays != null && totalDays > daysElapsed)
        ? totalDays
        : daysElapsed;

    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Progress Over Time',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: onSurface.withValues(alpha: 0.8)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [FlSpot(0, 0), FlSpot(daysElapsed, currentPct)],
                      isCurved: false,
                      color: color,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (s, x, bar, i) => FlDotCirclePainter(
                          radius: i == 1 ? 4 : 0,
                          color: color,
                          strokeWidth: 0,
                          strokeColor: Colors.transparent,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                    if (hasDeadline && totalDays! > 0)
                      LineChartBarData(
                        spots: [FlSpot(0, 0), FlSpot(totalDays, 100)],
                        isCurved: false,
                        color: onSurface.withValues(alpha: 0.3),
                        barWidth: 1.5,
                        dotData: const FlDotData(show: false),
                        dashArray: [5, 5],
                      ),
                  ],
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 25,
                        getTitlesWidget: (v, _) => Text(
                          '${v.toInt()}%',
                          style: TextStyle(
                              fontSize: 9,
                              color: onSurface.withValues(alpha: 0.4)),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: (maxX / 4).clamp(1, double.infinity),
                        getTitlesWidget: (v, _) => Text(
                          'd${v.toInt()}',
                          style: TextStyle(
                              fontSize: 9,
                              color: onSurface.withValues(alpha: 0.4)),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
