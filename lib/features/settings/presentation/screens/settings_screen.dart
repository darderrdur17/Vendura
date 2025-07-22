import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    print('[SettingsScreen] build: settings = ' + settings.toString());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        children: [
          // Auto Sync Status
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(
                  settings.autoSync ? Icons.sync : Icons.sync_disabled,
                  color: settings.autoSync ? AppTheme.successGreen : AppTheme.errorRed,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto Sync',
                        style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        settings.autoSync 
                            ? 'All changes are automatically synchronized'
                            : 'Manual sync required',
                        style: AppTheme.bodySmall.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: settings.autoSync,
                  onChanged: (value) {
                    print('[SettingsScreen] AutoSync toggled: ' + value.toString());
                    ref.read(settingsProvider.notifier).updateAutoSync(value);
                  },
                  activeColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Menu Management
          _buildSettingsSection(
            'Menu Management',
            Icons.restaurant_menu,
            [
              ListTile(
                leading: const Icon(Icons.inventory),
                title: const Text('Menu Management'),
                subtitle: const Text('Manage items, stock, and add-ons'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/menu-management'),
              ),
            ],
          ),
          
          // Receipt Settings
          _buildSettingsSection(
            'Receipt Settings',
            Icons.receipt,
            [
              ListTile(
                leading: const Icon(Icons.print),
                title: const Text('Receipt Settings'),
                subtitle: const Text('Configure receipt printing and formatting'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/receipt-settings'),
              ),
            ],
          ),
          
          // Backup & Restore
          _buildSettingsSection(
            'Backup & Restore',
            Icons.backup,
            [
              ListTile(
                leading: const Icon(Icons.cloud_upload),
                title: const Text('Backup & Restore'),
                subtitle: const Text('Manage data backup and restoration'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/backup-restore'),
              ),
            ],
          ),
          
          // Sync Settings
          _buildSettingsSection(
            'Sync Settings',
            Icons.sync,
            [
              ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Sync Settings'),
                subtitle: const Text('Configure data synchronization'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/sync-settings'),
              ),
            ],
          ),
          
          // App Details
          _buildSettingsSection(
            'App Information',
            Icons.info,
            [
              ListTile(
                leading: const Icon(Icons.app_settings_alt),
                title: const Text('App Details'),
                subtitle: const Text('Version, features, and technical info'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/app-details'),
              ),
            ],
          ),
          
          // Help & Support
          _buildSettingsSection(
            'Help & Support',
            Icons.help,
            [
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text('Help & Support'),
                subtitle: const Text('FAQs, contact, and troubleshooting'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/help-support'),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Quick Settings
          _buildSettingsSection(
            'Quick Settings',
            Icons.tune,
            [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Stock Alerts'),
                subtitle: const Text('Show low stock notifications'),
                value: settings.showStockAlerts,
                onChanged: (value) {
                  print('[SettingsScreen] StockAlerts toggled: ' + value.toString());
                  ref.read(settingsProvider.notifier).updateStockAlerts(value);
                },
                activeColor: AppTheme.primaryColor,
              ),
              ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Low Stock Threshold'),
                subtitle: Text('Alert when stock ≤ ${settings.lowStockThreshold}'),
                trailing: Text('${settings.lowStockThreshold}'),
                onTap: () => _showThresholdDialog(context, ref, settings.lowStockThreshold),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.add_circle_outline),
                title: const Text('Enable Add-ons'),
                subtitle: const Text('Allow item customization'),
                value: settings.enableAddOns,
                onChanged: (value) {
                  print('[SettingsScreen] AddOns toggled: ' + value.toString());
                  ref.read(settingsProvider.notifier).updateAddOns(value);
                },
                activeColor: AppTheme.primaryColor,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.print),
                title: const Text('Receipt Printing'),
                subtitle: const Text('Enable automatic receipt printing'),
                value: settings.enableReceiptPrinting,
                onChanged: (value) {
                  print('[SettingsScreen] ReceiptPrinting toggled: ' + value.toString());
                  ref.read(settingsProvider.notifier).updateReceiptPrinting(value);
                },
                activeColor: AppTheme.primaryColor,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.backup),
                title: const Text('Auto Backup'),
                subtitle: const Text('Automatically backup data'),
                value: settings.enableBackup,
                onChanged: (value) {
                  print('[SettingsScreen] Backup toggled: ' + value.toString());
                  ref.read(settingsProvider.notifier).updateBackup(value);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Reset Settings
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _showResetDialog(context, ref),
              icon: const Icon(Icons.restore),
              label: const Text('Reset to Defaults'),
              style: AppTheme.secondaryButtonStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Column(children: children),
        ),
        const SizedBox(height: AppTheme.spacingM),
      ],
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    print('[SettingsScreen] ShowResetDialog called');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to their default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('[SettingsScreen] Reset to defaults pressed');
              await ref.read(settingsProvider.notifier).resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showThresholdDialog(BuildContext context, WidgetRef ref, int current) {
    print('[SettingsScreen] ShowThresholdDialog called');
    double value = current.toDouble();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Low Stock Threshold'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: value,
                min: 1,
                max: 50,
                divisions: 49,
                label: value.round().toString(),
                onChanged: (v) => setState(() => value = v),
                activeColor: AppTheme.primaryColor,
              ),
              Text('Alert when stock is ${value.round()} or less'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              print('[SettingsScreen] Save threshold: ' + value.round().toString());
              ref.read(settingsProvider.notifier).updateLowStockThreshold(value.round());
              Navigator.pop(context);
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 