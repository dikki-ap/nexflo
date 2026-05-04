import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transaction_controller.dart';
import '../../../core/enums/filter_period.dart';

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransactionController>();
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
                  onSelected: (_) => ctrl.changePeriod(p),
                ),
              );
            }).toList(),
          ),
        ));
  }
}
