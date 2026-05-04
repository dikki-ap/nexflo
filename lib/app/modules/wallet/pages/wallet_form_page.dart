import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/wallet_type.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../domain/entities/wallet_entity.dart';

class WalletFormPage extends GetView<WalletController> {
  const WalletFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final existing = Get.arguments as WalletEntity?;
    final isEdit = existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Wallet' : 'New Wallet')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Wallet Name',
                hintText: 'e.g. Main Account',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<WalletType>(
                  value: controller.selectedType.value,
                  items: WalletType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) =>
                      controller.selectedType.value = v!,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                )),
            const SizedBox(height: 16),
            TextField(
              controller: controller.balanceCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Initial Balance',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.selectedType.value == WalletType.creditCard) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: controller.creditLimitCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Credit Limit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            _CurrencyPicker(controller),
            const SizedBox(height: 16),
            _ColorPicker(controller),
            const SizedBox(height: 16),
            _IconPicker(controller),
            const SizedBox(height: 16),
            Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Exclude from Net Worth'),
                  subtitle: const Text(
                    'Savings goals / loans you want to track separately',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: controller.isExcludeTotal.value,
                  onChanged: (v) =>
                      controller.isExcludeTotal.value = v,
                )),
            const SizedBox(height: 24),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.save(existing),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Save Changes' : 'Create Wallet'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  final WalletController ctrl;
  const _CurrencyPicker(this.ctrl);

  static const _currencies = [
    'IDR', 'USD', 'EUR', 'GBP', 'JPY', 'SGD', 'MYR',
    'AUD', 'CAD', 'CHF', 'CNY', 'HKD', 'KRW', 'INR',
    'THB', 'PHP', 'VND', 'TWD', 'NZD', 'AED',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<String>(
          value: ctrl.selectedCurrency.value,
          items: _currencies
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => ctrl.selectedCurrency.value = v!,
          decoration: const InputDecoration(
            labelText: 'Currency',
            border: OutlineInputBorder(),
          ),
        ));
  }
}

class _ColorPicker extends StatelessWidget {
  final WalletController ctrl;
  const _ColorPicker(this.ctrl);

  static const _colors = [
    AppColors.teal, AppColors.blue, AppColors.purple,
    AppColors.green, AppColors.orange, AppColors.pink,
    Color(0xFF795548), Color(0xFF607D8B), Color(0xFF9E9E9E),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color',
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 10,
              children: _colors
                  .map((c) => GestureDetector(
                        onTap: () => ctrl.selectedColor.value = c,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: ctrl.selectedColor.value == c
                                ? Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                    width: 3)
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}

class _IconPicker extends StatelessWidget {
  final WalletController ctrl;
  const _IconPicker(this.ctrl);

  static const _icons = [
    'wallet', 'account_balance', 'credit_card', 'savings',
    'monetization_on', 'payment', 'local_atm', 'shopping_bag',
    'work', 'home', 'directions_car', 'flight',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icon',
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6))),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _icons
                  .map((name) => GestureDetector(
                        onTap: () => ctrl.selectedIcon.value = name,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: ctrl.selectedIcon.value == name
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(IconMapper.get(name), size: 22),
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}
