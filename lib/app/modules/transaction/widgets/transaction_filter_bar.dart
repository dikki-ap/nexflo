import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../../../core/enums/filter_period.dart';

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransactionController>();
    final scheme = Theme.of(context).colorScheme;
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: FilterPeriod.values.map((p) {
              final selected = ctrl.selectedPeriod.value == p;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(p.label),
                  selected: selected,
                  selectedColor: scheme.primary.withValues(alpha: 0.18),
                  checkmarkColor: scheme.primary,
                  labelStyle: TextStyle(
                    color: selected ? scheme.primary : null,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: selected
                        ? scheme.primary
                        : scheme.outline.withValues(alpha: 0.4),
                  ),
                  onSelected: (_) => _onTap(context, ctrl, p),
                ),
              );
            }).toList(),
          ),
        ));
  }

  Future<void> _onTap(
      BuildContext context, TransactionController ctrl, FilterPeriod p) async {
    if (p == FilterPeriod.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        initialDateRange: ctrl.customStart != null && ctrl.customEnd != null
            ? DateTimeRange(start: ctrl.customStart!, end: ctrl.customEnd!)
            : null,
      );
      if (range != null) {
        ctrl.applyCustomRange(range.start, range.end);
      }
    } else {
      ctrl.changePeriod(p);
    }
  }
}
