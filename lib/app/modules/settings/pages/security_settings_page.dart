import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class SecuritySettingsPage extends GetView<SettingsController> {
  const SecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: Obx(() {
        final s = controller.settings.value;
        return ListView(
          children: [
            _SectionHeader('Biometric'),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Unlock'),
              subtitle: controller.isBiometricAvailable
                  ? null
                  : const Text('Not available on this device',
                      style: TextStyle(color: Colors.grey)),
              value: s?.isBiometricEnabled ?? false,
              onChanged: controller.isBiometricAvailable
                  ? controller.toggleBiometric
                  : null,
            ),
            const Divider(height: 1),
            _SectionHeader('PIN Lock'),
            if (s?.isPinEnabled == true) ...[
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.green),
                title: const Text('PIN is enabled'),
                subtitle: const Text('Tap to change PIN'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPinSetup(context, isChange: true),
              ),
              ListTile(
                leading: const Icon(Icons.lock_open, color: Colors.red),
                title: const Text('Remove PIN'),
                onTap: () => _confirmRemovePin(context),
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.add_moderator_outlined),
                title: const Text('Set up PIN'),
                subtitle: const Text('4–6 digit PIN for app lock'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPinSetup(context),
              ),
            const Divider(height: 1),
            _SectionHeader('Note'),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'When lock is enabled, you will be prompted to authenticate on app launch.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showPinSetup(BuildContext context, {bool isChange = false}) {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    if (isChange) {
      showDialog(
        context: context,
        builder: (_) => _VerifyPinDialog(
          onVerified: () {
            Get.back();
            _showNewPinDialog(context);
          },
          controller: controller,
        ),
      );
    } else {
      _showNewPinDialog(context);
    }
  }

  void _showNewPinDialog(BuildContext context) {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                labelText: 'New PIN (4–6 digits)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: const InputDecoration(
                labelText: 'Confirm PIN',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final pin = pinCtrl.text;
              final confirm = confirmCtrl.text;
              if (pin.length < 4) {
                Get.snackbar('Error', 'PIN must be at least 4 digits');
                return;
              }
              if (pin != confirm) {
                Get.snackbar('Error', 'PINs do not match');
                return;
              }
              Get.back();
              controller.setupPin(pin);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmRemovePin(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _VerifyPinDialog(
        onVerified: () {
          Get.back();
          controller.removePin();
        },
        controller: controller,
      ),
    );
  }
}

class _VerifyPinDialog extends StatelessWidget {
  final VoidCallback onVerified;
  final SettingsController controller;

  const _VerifyPinDialog({
    required this.onVerified,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final pinCtrl = TextEditingController();

    return AlertDialog(
      title: const Text('Enter Current PIN'),
      content: TextField(
        controller: pinCtrl,
        obscureText: true,
        keyboardType: TextInputType.number,
        autofocus: true,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        decoration: const InputDecoration(
          labelText: 'Current PIN',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (controller.verifyPin(pinCtrl.text)) {
              onVerified();
            } else {
              Get.snackbar('Error', 'Incorrect PIN',
                  snackPosition: SnackPosition.BOTTOM);
            }
          },
          child: const Text('Verify'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
