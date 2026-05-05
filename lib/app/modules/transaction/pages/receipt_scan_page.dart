import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/receipt_scan_controller.dart';

class ReceiptScanPage extends GetView<ReceiptScanController> {
  const ReceiptScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        actions: [
          Obx(() {
            if (controller.result == null) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.useResult,
              child: const Text('Use'),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.imagePath == null) {
          return _PickerView(controller);
        }
        if (controller.isProcessing) {
          return const _ProcessingView();
        }
        if (controller.error.isNotEmpty) {
          return _ErrorView(controller);
        }
        return _ResultView(controller);
      }),
    );
  }
}

class _PickerView extends StatelessWidget {
  final ReceiptScanController ctrl;
  const _PickerView(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 24),
          Text(
            'Scan a receipt to\npre-fill transaction details',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 40),
          FilledButton.icon(
            onPressed: ctrl.pickFromCamera,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Take Photo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: ctrl.pickFromGallery,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose from Gallery'),
          ),
        ],
      ),
    );
  }
}

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Reading receipt…'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final ReceiptScanController ctrl;
  const _ErrorView(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(ctrl.error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: ctrl.retry, child: const Text('Try Again')),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final ReceiptScanController ctrl;
  const _ResultView(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final result = ctrl.result!;

    return Column(
      children: [
        // Image preview
        if (ctrl.imagePath != null)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(ctrl.imagePath!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Detected Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              _DetectedField(
                label: 'Amount',
                value: result.amount != null
                    ? result.amount!.toStringAsFixed(2)
                    : null,
                icon: Icons.attach_money,
                found: result.amount != null,
              ),
              const SizedBox(height: 12),
              _DetectedField(
                label: 'Date',
                value: result.date != null
                    ? DateFormat('d MMM yyyy').format(result.date!)
                    : null,
                icon: Icons.calendar_today,
                found: result.date != null,
              ),
              const SizedBox(height: 12),
              _DetectedField(
                label: 'Merchant',
                value: result.merchant,
                icon: Icons.store_outlined,
                found: result.merchant != null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: ctrl.retry,
                      child: const Text('Retake'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: ctrl.useResult,
                      child: const Text('Use Data'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetectedField extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final bool found;

  const _DetectedField({
    required this.label,
    required this.value,
    required this.icon,
    required this.found,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: found
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: found
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: found
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
                Text(
                  value ?? 'Not detected',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: found ? FontWeight.w600 : FontWeight.normal,
                        color: found
                            ? null
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.4),
                      ),
                ),
              ],
            ),
          ),
          Icon(
            found ? Icons.check_circle : Icons.radio_button_unchecked,
            color: found ? Colors.green : Colors.grey,
            size: 18,
          ),
        ],
      ),
    );
  }
}
