import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

import '../../../config/theme/app_theme_controller.dart';
import '../../../core/enums/theme_color.dart';
import '../controllers/settings_controller.dart';

class ThemeSettingsPage extends GetView<SettingsController> {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<AppThemeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Theme')),
      body: ListView(
        children: [
          _SectionHeader('Appearance'),
          GetBuilder<AppThemeController>(
            builder: (tc) => Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  secondary: const Icon(Icons.brightness_auto),
                  value: ThemeMode.system,
                  groupValue: tc.themeMode,
                  onChanged: (v) => tc.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  secondary: const Icon(Icons.light_mode_outlined),
                  value: ThemeMode.light,
                  groupValue: tc.themeMode,
                  onChanged: (v) => tc.setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: ThemeMode.dark,
                  groupValue: tc.themeMode,
                  onChanged: (v) => tc.setThemeMode(v!),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _SectionHeader('Accent Color'),
          GetBuilder<AppThemeController>(
            builder: (tc) => Column(
              children: [
                ...ThemeColor.values
                    .where((c) => c != ThemeColor.custom)
                    .map((color) => _ColorTile(
                          label: _colorLabel(color),
                          color: color.color,
                          isSelected: tc.themeColorEnum == color,
                          onTap: () => tc.setThemeColor(color),
                        )),
                ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(colors: [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.purple,
                        Colors.red,
                      ]),
                    ),
                    child: tc.themeColorEnum == ThemeColor.custom
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                  title: const Text('Custom Color'),
                  trailing: tc.themeColorEnum == ThemeColor.custom
                      ? Icon(Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () => _showCustomColorPicker(context, themeCtrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _colorLabel(ThemeColor color) {
    return switch (color) {
      ThemeColor.teal => 'Teal (Default)',
      ThemeColor.blue => 'Blue',
      ThemeColor.purple => 'Purple',
      ThemeColor.green => 'Green',
      ThemeColor.orange => 'Orange',
      ThemeColor.pink => 'Pink',
      ThemeColor.custom => 'Custom',
    };
  }

  void _showCustomColorPicker(
      BuildContext context, AppThemeController themeCtrl) {
    Color picked = themeCtrl.accentColor;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: picked,
            onColorChanged: (c) => picked = c,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final hex =
                  '#${picked.red.toRadixString(16).padLeft(2, '0')}${picked.green.toRadixString(16).padLeft(2, '0')}${picked.blue.toRadixString(16).padLeft(2, '0')}';
              themeCtrl.setThemeColor(ThemeColor.custom, customHex: hex);
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorTile({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : null,
      ),
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
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
