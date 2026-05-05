import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/sync_service.dart';
import '../controllers/settings_controller.dart';

class SyncSettingsPage extends GetView<SettingsController> {
  const SyncSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sheets Sync'),
        actions: [
          Obx(() => controller.isSyncing
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Sync Now',
                  onPressed: controller.triggerSync,
                )),
        ],
      ),
      body: Obx(() {
        final s = controller.settings.value;
        final hasSpreadsheet =
            s?.sheetsSpreadsheetId != null && s!.sheetsSpreadsheetId!.isNotEmpty;

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Status card
            _StatusCard(
              state: controller.syncState,
              lastSyncAt: s?.lastSyncAt,
              isSyncing: controller.isSyncing,
            ),
            const SizedBox(height: 8),

            // Sync toggle
            SwitchListTile(
              secondary: const Icon(Icons.cloud_sync_outlined),
              title: const Text('Enable Sync'),
              subtitle: const Text('Automatically sync changes to Google Sheets'),
              value: s?.syncEnabled ?? true,
              onChanged: controller.toggleSyncEnabled,
            ),

            // Manual sync
            ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Sync Now'),
              subtitle: const Text('Push all pending changes to Google Sheets'),
              trailing: const Icon(Icons.chevron_right),
              onTap: controller.triggerSync,
            ),

            if (hasSpreadsheet) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'SPREADSHEET',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined),
                title: const Text('Spreadsheet ID'),
                subtitle: Text(
                  s!.sheetsSpreadsheetId!,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.link_off, color: Colors.red),
                title: const Text('Disconnect Sheets',
                    style: TextStyle(color: Colors.red)),
                subtitle: const Text(
                    'Remove spreadsheet link (data stays on device)'),
                onTap: () => _confirmDisconnect(context),
              ),
            ],

            if (!hasSpreadsheet) ...[
              const Divider(),
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Not Connected'),
                subtitle: Text(
                    'A spreadsheet will be created automatically on your first sync.'),
              ),
            ],
          ],
        );
      }),
    );
  }

  void _confirmDisconnect(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Disconnect Sheets?'),
        content: const Text(
          'This removes the link to your spreadsheet. Your local data is safe. '
          'A new spreadsheet will be created on the next sync.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.disconnectSheets();
            },
            child: const Text('Disconnect',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final SyncState state;
  final DateTime? lastSyncAt;
  final bool isSyncing;

  const _StatusCard({
    required this.state,
    required this.lastSyncAt,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context) {
    final color = _stateColor(context);
    final icon = _stateIcon();
    final label = _stateLabel();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            isSyncing
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: color)),
                  if (lastSyncAt != null)
                    Text(
                      'Last sync: ${_fmtDate(lastSyncAt!)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _stateColor(BuildContext context) {
    switch (state) {
      case SyncState.syncing:
        return Theme.of(context).colorScheme.primary;
      case SyncState.success:
        return Colors.green;
      case SyncState.error:
        return Colors.red;
      case SyncState.idle:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    }
  }

  IconData _stateIcon() {
    switch (state) {
      case SyncState.success:
        return Icons.cloud_done_outlined;
      case SyncState.error:
        return Icons.cloud_off_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }

  String _stateLabel() {
    switch (state) {
      case SyncState.syncing:
        return 'Syncing...';
      case SyncState.success:
        return 'Sync complete';
      case SyncState.error:
        return 'Sync failed — will retry';
      case SyncState.idle:
        return 'Ready to sync';
    }
  }

  String _fmtDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
