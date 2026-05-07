import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final hPad = context.horizontalPadding;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerLoading(
            isLoading: true,
            child: ListView(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 40),
              children: [
                const ShimmerCard(height: 100, horizontalMargin: 0, borderRadius: 20),
                const SizedBox(height: 20),
                const ShimmerCard(height: 180, horizontalMargin: 0, borderRadius: 18),
                const SizedBox(height: 16),
                const ShimmerCard(height: 120, horizontalMargin: 0, borderRadius: 18),
              ],
            ),
          );
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 40),
          children: [
            _ProfileCard(controller, isDark),
            const SizedBox(height: 24),
            _SettingsGroup(
              label: 'Preferences',
              isDark: isDark,
              tiles: [
                _SettingTile(
                  icon: Icons.language_rounded,
                  label: 'Base Currency',
                  value: controller.settings.value?.baseCurrencyCode ?? 'USD',
                  isDark: isDark,
                  onTap: () => Get.toNamed(AppRoutes.settingsCurrency),
                ),
                _SettingTile(
                  icon: Icons.date_range_rounded,
                  label: 'Cutoff Date',
                  value: 'Day ${controller.settings.value?.cutoffDate ?? 1}',
                  isDark: isDark,
                  onTap: () => _showCutoffDatePicker(context),
                ),
                _SettingTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Theme',
                  value: _themeLabel(controller.settings.value?.themeMode ?? 'system'),
                  isDark: isDark,
                  onTap: () => Get.toNamed(AppRoutes.settingsTheme),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              label: 'Sync',
              isDark: isDark,
              tiles: [
                _SettingTile(
                  icon: Icons.cloud_sync_outlined,
                  label: 'Google Sheets Sync',
                  isDark: isDark,
                  onTap: () => Get.toNamed(AppRoutes.settingsSync),
                ),
              ],
              trailing: Obx(() {
                final syncEnabled =
                    controller.settings.value?.syncEnabled ?? true;
                return _SwitchTile(
                  icon: syncEnabled ? Icons.sync_rounded : Icons.sync_disabled_rounded,
                  label: 'Sync Enabled',
                  value: syncEnabled,
                  isDark: isDark,
                  onChanged: controller.toggleSyncEnabled,
                );
              }),
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              label: 'Security',
              isDark: isDark,
              tiles: [
                _SettingTile(
                  icon: Icons.security_outlined,
                  label: 'Biometric & PIN Lock',
                  isDark: isDark,
                  onTap: () => Get.toNamed(AppRoutes.settingsSecurity),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final s = controller.settings.value;
              return _SettingsGroup(
                label: 'Notifications',
                isDark: isDark,
                trailing: Column(
                  children: [
                    _SwitchTile(
                      icon: Icons.pie_chart_outline_rounded,
                      label: 'Budget Alerts',
                      value: s?.notificationBudgetAlert ?? true,
                      isDark: isDark,
                      onChanged: controller.toggleBudgetAlert,
                    ),
                    _SwitchTile(
                      icon: Icons.repeat_rounded,
                      label: 'Recurring Reminders',
                      value: s?.notificationRecurringReminder ?? true,
                      isDark: isDark,
                      onChanged: controller.toggleRecurringReminder,
                    ),
                    _SwitchTile(
                      icon: Icons.handshake_outlined,
                      label: 'Debt Reminders',
                      value: s?.notificationDebtReminder ?? true,
                      isDark: isDark,
                      onChanged: controller.toggleDebtReminder,
                      isLast: true,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            _SettingsGroup(
              label: 'Data',
              isDark: isDark,
              tiles: [
                _SettingTile(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Export PDF',
                  value: 'Summary report',
                  isDark: isDark,
                  onTap: controller.exportPdf,
                ),
                _SettingTile(
                  icon: Icons.download_outlined,
                  label: 'Export JSON',
                  value: 'Full backup',
                  isDark: isDark,
                  onTap: controller.exportJson,
                ),
                _SettingTile(
                  icon: Icons.delete_sweep_outlined,
                  label: 'Clear All Data',
                  isDark: isDark,
                  isDestructive: true,
                  isLast: true,
                  onTap: controller.clearAllData,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsGroup(
              label: 'About',
              isDark: isDark,
              tiles: [
                _SettingTile(
                  icon: Icons.info_outline_rounded,
                  label: 'Version',
                  value: '1.0.0',
                  isDark: isDark,
                  isLast: true,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }

  void _showCutoffDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cutoff Date'),
        content: SizedBox(
          width: 200,
          height: 300,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 40,
            onSelectedItemChanged: (i) => controller.updateCutoffDate(i + 1),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (_, i) => Center(
                child: Text('Day ${i + 1}',
                    style: const TextStyle(fontSize: 16)),
              ),
              childCount: 28,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final SettingsController ctrl;
  final bool isDark;
  const _ProfileCard(this.ctrl, this.isDark);

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: ctrl.userPhotoUrl != null
                ? NetworkImage(ctrl.userPhotoUrl!)
                : null,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: ctrl.userPhotoUrl == null
                ? const Icon(Icons.person_rounded,
                    color: Colors.white, size: 28)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ctrl.userName ?? 'User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  ctrl.userEmail ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: ctrl.signOut,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String label;
  final bool isDark;
  final List<_SettingTile> tiles;
  final Widget? trailing;
  const _SettingsGroup({
    required this.label,
    required this.isDark,
    this.tiles = const [],
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          label: label,
          padding: const EdgeInsets.only(bottom: 10),
        ),
        GlassCard(
          borderRadius: 18,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ...tiles,
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool isDark;
  final bool isDestructive;
  final bool isLast;
  final VoidCallback? onTap;
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.isDark,
    this.value,
    this.isDestructive = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final labelColor = isDestructive
        ? AppColors.expense
        : (isDark ? Colors.white : AppColors.grey900);
    final iconColor = isDestructive
        ? AppColors.expense
        : primary;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: isLast ? Radius.zero : const Radius.circular(18),
            bottom: isLast ? const Radius.circular(18) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.expense.withValues(alpha: 0.10)
                        : primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: labelColor,
                    ),
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.45)
                          : AppColors.grey500,
                    ),
                  ),
                if (onTap != null && !isDestructive) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : AppColors.grey400,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: isDark ? AppColors.glassBorder : AppColors.grey200,
          ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final bool isDark;
  final bool isLast;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.grey900,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 64,
            endIndent: 16,
            color: isDark ? AppColors.glassBorder : AppColors.grey200,
          ),
      ],
    );
  }
}
