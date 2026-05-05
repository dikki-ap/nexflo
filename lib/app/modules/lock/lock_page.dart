import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'lock_controller.dart';

class LockPage extends GetView<LockController> {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.lock_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'NexFlo',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter PIN to unlock',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
            ),
            const SizedBox(height: 40),
            _PinDots(controller),
            const Spacer(),
            _Keypad(controller),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final LockController ctrl;
  const _PinDots(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (i) {
                final filled = i < ctrl.pin.length;
                final isError = ctrl.isError;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isError
                        ? Colors.red
                        : filled
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                  ),
                );
              }),
            )),
        const SizedBox(height: 12),
        Obx(() => AnimatedOpacity(
              opacity: ctrl.isError ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Text(
                'Incorrect PIN — try again',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            )),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  final LockController ctrl;
  const _Keypad(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _KeyRow(['1', '2', '3'], ctrl),
          _KeyRow(['4', '5', '6'], ctrl),
          _KeyRow(['7', '8', '9'], ctrl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(() => _KeyButton(
                    icon: ctrl.isBiometricAttempting
                        ? null
                        : Icons.fingerprint,
                    isLoading: ctrl.isBiometricAttempting,
                    onTap: ctrl.retryBiometric,
                  )),
              _KeyButton(
                label: '0',
                onTap: () => ctrl.addDigit('0'),
              ),
              _KeyButton(
                icon: Icons.backspace_outlined,
                onTap: ctrl.removeDigit,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyRow extends StatelessWidget {
  final List<String> digits;
  final LockController ctrl;
  const _KeyRow(this.digits, this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits
          .map((d) => _KeyButton(
                label: d,
                onTap: () => ctrl.addDigit(d),
              ))
          .toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _KeyButton({
    this.label,
    this.icon,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : label != null
                  ? Text(
                      label!,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Icon(icon, size: 24),
        ),
      ),
    );
  }
}
