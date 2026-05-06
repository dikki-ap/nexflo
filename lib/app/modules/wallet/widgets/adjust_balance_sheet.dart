import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../domain/entities/wallet_entity.dart';
import '../../../services/currency_service.dart';
import '../controllers/wallet_controller.dart';

class AdjustBalanceSheet extends StatefulWidget {
  final WalletEntity wallet;
  const AdjustBalanceSheet({super.key, required this.wallet});

  @override
  State<AdjustBalanceSheet> createState() => _AdjustBalanceSheetState();
}

class _AdjustBalanceSheetState extends State<AdjustBalanceSheet> {
  final _ctrl = TextEditingController();
  bool _withRecord = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl.text = widget.wallet.balance.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adjust Balance — ${widget.wallet.name}',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText: 'New Balance',
              prefixText: '${Get.find<CurrencyService>().baseCurrency} ',
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Create adjustment transaction'),
            subtitle: Text(
              _withRecord
                  ? 'Income/expense record will be created'
                  : 'Balance updated silently',
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55)),
            ),
            value: _withRecord,
            onChanged: (v) => setState(() => _withRecord = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Adjust'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final newBalance = double.tryParse(_ctrl.text.replaceAll(',', ''));
    if (newBalance == null) {
      Get.snackbar('Error', 'Invalid amount');
      return;
    }
    setState(() => _loading = true);
    await Get.find<WalletController>().adjustBalance(
      wallet: widget.wallet,
      newBalance: newBalance,
      withRecord: _withRecord,
    );
  }
}
