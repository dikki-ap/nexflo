import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: [
            _ProfileSection(controller),
            const Divider(height: 1),
            _PreferencesSection(controller),
            const Divider(height: 1),
            _ThemeSection(controller),
            const Divider(height: 1),
            _SecuritySection(controller),
            const Divider(height: 1),
            _SyncSection(controller),
            const Divider(height: 1),
            _NotificationsSection(controller),
            const Divider(height: 1),
            _DataSection(controller),
            const Divider(height: 1),
            _AboutSection(),
          ],
        );
      }),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final SettingsController ctrl;
  const _ProfileSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Account'),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: ctrl.userPhotoUrl != null
                ? NetworkImage(ctrl.userPhotoUrl!)
                : null,
            child: ctrl.userPhotoUrl == null
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(ctrl.userName ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(ctrl.userEmail ?? ''),
          trailing: TextButton(
            onPressed: ctrl.signOut,
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  final SettingsController ctrl;
  const _PreferencesSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    final s = ctrl.settings.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Preferences'),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Base Currency'),
          subtitle: Text(s?.baseCurrencyCode ?? 'USD'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.toNamed(AppRoutes.settingsCurrency),
        ),
        ListTile(
          leading: const Icon(Icons.date_range),
          title: const Text('Cutoff Date'),
          subtitle: Text('Day ${s?.cutoffDate ?? 1} of each month'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showCutoffDatePicker(context),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode_outlined),
          title: const Text('Theme'),
          subtitle: Text(_themeLabel(s?.themeMode ?? 'system')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemePicker(context),
        ),
      ],
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
            onSelectedItemChanged: (i) => ctrl.updateCutoffDate(i + 1),
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

  void _showThemePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Theme'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              ctrl.updateThemeMode('light');
              Get.back();
            },
            child: const Text('Light'),
          ),
          SimpleDialogOption(
            onPressed: () {
              ctrl.updateThemeMode('dark');
              Get.back();
            },
            child: const Text('Dark'),
          ),
          SimpleDialogOption(
            onPressed: () {
              ctrl.updateThemeMode('system');
              Get.back();
            },
            child: const Text('System Default'),
          ),
        ],
      ),
    );
  }
}

class _SyncSection extends StatelessWidget {
  final SettingsController ctrl;
  const _SyncSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Sync'),
        ListTile(
          leading: const Icon(Icons.cloud_sync_outlined),
          title: const Text('Google Sheets Sync'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.toNamed(AppRoutes.settingsSync),
        ),
        Obx(() {
          final s = ctrl.settings.value;
          final syncEnabled = s?.syncEnabled ?? true;
          return SwitchListTile(
            secondary: Icon(
              syncEnabled
                  ? Icons.sync
                  : Icons.sync_disabled,
            ),
            title: const Text('Sync Enabled'),
            value: syncEnabled,
            onChanged: ctrl.toggleSyncEnabled,
          );
        }),
      ],
    );
  }
}

class _NotificationsSection extends StatelessWidget {
  final SettingsController ctrl;
  const _NotificationsSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = ctrl.settings.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader('Notifications'),
          SwitchListTile(
            secondary: const Icon(Icons.pie_chart_outline),
            title: const Text('Budget Alerts'),
            value: s?.notificationBudgetAlert ?? true,
            onChanged: ctrl.toggleBudgetAlert,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.repeat),
            title: const Text('Recurring Reminders'),
            value: s?.notificationRecurringReminder ?? true,
            onChanged: ctrl.toggleRecurringReminder,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.handshake_outlined),
            title: const Text('Debt Reminders'),
            value: s?.notificationDebtReminder ?? true,
            onChanged: ctrl.toggleDebtReminder,
          ),
        ],
      );
    });
  }
}

class _ThemeSection extends StatelessWidget {
  final SettingsController ctrl;
  const _ThemeSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Theme'),
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: const Text('Appearance & Colors'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.toNamed(AppRoutes.settingsTheme),
        ),
      ],
    );
  }
}

class _SecuritySection extends StatelessWidget {
  final SettingsController ctrl;
  const _SecuritySection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Security'),
        ListTile(
          leading: const Icon(Icons.security_outlined),
          title: const Text('Biometric & PIN Lock'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Get.toNamed(AppRoutes.settingsSecurity),
        ),
      ],
    );
  }
}

class _DataSection extends StatelessWidget {
  final SettingsController ctrl;
  const _DataSection(this.ctrl);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('Data'),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf_outlined),
          title: const Text('Export PDF'),
          subtitle: const Text('Summary report'),
          trailing: const Icon(Icons.chevron_right),
          onTap: ctrl.exportPdf,
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Export JSON'),
          subtitle: const Text('Full backup'),
          trailing: const Icon(Icons.chevron_right),
          onTap: ctrl.exportJson,
        ),
        ListTile(
          leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
          title: const Text('Clear All Data',
              style: TextStyle(color: Colors.red)),
          subtitle: const Text('Permanently delete everything'),
          onTap: ctrl.clearAllData,
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader('About'),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Licenses'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(context: context, applicationName: 'NexFlo'),
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
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
