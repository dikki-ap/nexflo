import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/currency_service.dart';
import '../controllers/settings_controller.dart';

class CurrencySettingsPage extends GetView<SettingsController> {
  const CurrencySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Rates',
            onPressed: controller.refreshRates,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _BaseCurrencySection(controller),
          const Divider(),
          _ExchangeRatesSection(controller),
          const Divider(),
          _ManualRateSection(controller),
        ],
      ),
    );
  }
}

class _BaseCurrencySection extends StatelessWidget {
  final SettingsController ctrl;
  const _BaseCurrencySection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Base Currency'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'All statistics and multi-currency conversions use this currency.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final currentCode = ctrl.settings.value?.baseCurrencyCode ?? 'USD';
          return Column(
            children: ctrl.currencies.map((currency) {
              final isSelected = currency.code == currentCode;
              return ListTile(
                leading: Text(currency.flagEmoji,
                    style: const TextStyle(fontSize: 24)),
                title: Text(currency.name),
                subtitle: Text(currency.code),
                trailing: isSelected
                    ? Icon(Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () => ctrl.updateBaseCurrency(currency.code),
                selected: isSelected,
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _ExchangeRatesSection extends StatelessWidget {
  final SettingsController ctrl;
  const _ExchangeRatesSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final currencyService = Get.find<CurrencyService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Live Rates'),
        Obx(() {
          final rates = currencyService.currentRates;
          final base = currencyService.baseCurrency;
          if (rates.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No rates cached. Tap refresh to fetch.',
                  style: TextStyle(color: Colors.grey)),
            );
          }
          final sorted = rates.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
          return Column(
            children: sorted.map((e) {
              return ListTile(
                dense: true,
                title: Text('${e.key} / $base'),
                trailing: Text(
                  e.value.toStringAsFixed(4),
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontFamily: 'monospace'),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _ManualRateSection extends StatelessWidget {
  final SettingsController ctrl;
  const _ManualRateSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Manual Rate Override'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Override a specific exchange rate when offline or for custom rates.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() => Row(
                children: [
                  Expanded(
                    child: _CurrencyDropdown(
                      label: 'From',
                      value: ctrl.manualRateFrom.value.isNotEmpty
                          ? ctrl.manualRateFrom.value
                          : null,
                      currencies: ctrl.currencies,
                      onChanged: (v) => ctrl.manualRateFrom.value = v ?? '',
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, size: 18),
                  ),
                  Expanded(
                    child: _CurrencyDropdown(
                      label: 'To',
                      value: ctrl.manualRateTo.value.isNotEmpty
                          ? ctrl.manualRateTo.value
                          : null,
                      currencies: ctrl.currencies,
                      onChanged: (v) => ctrl.manualRateTo.value = v ?? '',
                    ),
                  ),
                ],
              )),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Rate',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) =>
                      ctrl.manualRateValue.value = double.tryParse(v) ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: ctrl.saveManualRate,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CurrencyDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List currencies;
  final void Function(String?) onChanged;

  const _CurrencyDropdown({
    required this.label,
    required this.value,
    required this.currencies,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: currencies.map<DropdownMenuItem<String>>((c) {
        return DropdownMenuItem(
          value: c.code as String,
          child: Text(c.code as String),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
