import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  bool _autoSyncEnabled = true;
  bool _syncOnWifiOnly = true;
  bool _syncOrders = true;
  bool _syncInventory = true;
  bool _syncReceipts = true;
  bool _syncSettings = true;
  String _syncFrequency = 'Real-time';
  DateTime _lastSync = DateTime.now().subtract(const Duration(minutes: 15));
  bool _isSyncing = false;

  final List<String> _syncFrequencies = ['Real-time', 'Every 15 minutes', 'Every hour', 'Daily'];

  final List<Map<String, dynamic>> _syncHistory = [
    {
      'date': DateTime.now().subtract(const Duration(minutes: 15)),
      'type': 'Orders',
      'status': 'Completed',
      'items': 3,
    },
    {
      'date': DateTime.now().subtract(const Duration(minutes: 30)),
      'type': 'Inventory',
      'status': 'Completed',
      'items': 12,
    },
    {
      'date': DateTime.now().subtract(const Duration(hours: 1)),
      'type': 'Settings',
      'status': 'Completed',
      'items': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _manualSync,
            icon: const Icon(Icons.sync),
            tooltip: 'Manual Sync',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sync,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Sync',
                              style: AppTheme.titleSmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatDateTime(_lastSync),
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          'Connected',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isSyncing) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    const LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Syncing data...',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Sync Settings
            _buildSectionHeader('Sync Settings', Icons.settings),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Auto Sync'),
                    subtitle: const Text('Automatically sync data'),
                    value: _autoSyncEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoSyncEnabled = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Sync on WiFi Only'),
                    subtitle: const Text('Save mobile data'),
                    value: _syncOnWifiOnly,
                    onChanged: (value) {
                      setState(() {
                        _syncOnWifiOnly = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    title: const Text('Sync Frequency'),
                    subtitle: Text(_syncFrequency),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showFrequencyDialog(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Data Types
            _buildSectionHeader('Data Types', Icons.data_usage),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Orders'),
                    subtitle: const Text('Sync order data'),
                    value: _syncOrders,
                    onChanged: (value) {
                      setState(() {
                        _syncOrders = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Inventory'),
                    subtitle: const Text('Sync inventory data'),
                    value: _syncInventory,
                    onChanged: (value) {
                      setState(() {
                        _syncInventory = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Receipts'),
                    subtitle: const Text('Sync receipt data'),
                    value: _syncReceipts,
                    onChanged: (value) {
                      setState(() {
                        _syncReceipts = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Settings'),
                    subtitle: const Text('Sync app settings'),
                    value: _syncSettings,
                    onChanged: (value) {
                      setState(() {
                        _syncSettings = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Manual Sync
            _buildSectionHeader('Manual Sync', Icons.sync),
            const SizedBox(height: AppTheme.spacingM),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _manualSync,
                icon: const Icon(Icons.sync),
                label: const Text('Sync Now'),
                style: AppTheme.primaryButtonStyle,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Sync History
            _buildSectionHeader('Sync History', Icons.history),
            const SizedBox(height: AppTheme.spacingM),
            
            ..._syncHistory.map((sync) => _buildSyncHistoryCard(sync)).toList(),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Device Management
            _buildSectionHeader('Device Management', Icons.devices),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_android, color: Colors.blue),
                    title: const Text('This Device'),
                    subtitle: const Text('iPhone 15 Pro • iOS 17.1'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.tablet_android, color: Colors.orange),
                    title: const Text('iPad Pro'),
                    subtitle: const Text('iPad Pro • iOS 17.1'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        'Offline',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.computer, color: Colors.purple),
                    title: const Text('MacBook Pro'),
                    subtitle: const Text('MacBook Pro • macOS 14.1'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Advanced Settings
            _buildSectionHeader('Advanced Settings', Icons.tune),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_upload, color: Colors.blue),
                    title: const Text('Upload to Cloud'),
                    subtitle: const Text('Manually upload data'),
                    onTap: _uploadToCloud,
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.cloud_download, color: Colors.green),
                    title: const Text('Download from Cloud'),
                    subtitle: const Text('Manually download data'),
                    onTap: _downloadFromCloud,
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.delete_sweep, color: Colors.red),
                    title: const Text('Clear Sync Data'),
                    subtitle: const Text('Remove all sync data'),
                    onTap: _clearSyncData,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
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
    );
  }

  Widget _buildSyncHistoryCard(Map<String, dynamic> sync) {
    final date = sync['date'] as DateTime;
    final type = sync['type'] as String;
    final status = sync['status'] as String;
    final items = sync['items'] as int;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            Icons.sync,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          type,
          style: AppTheme.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${items} items • ${_formatDateTime(date)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: status == 'Completed' 
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: status == 'Completed' ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showFrequencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _syncFrequencies.map((frequency) {
            return RadioListTile<String>(
              title: Text(frequency),
              value: frequency,
              groupValue: _syncFrequency,
              onChanged: (value) {
                setState(() {
                  _syncFrequency = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _manualSync() async {
    setState(() {
      _isSyncing = true;
    });

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isSyncing = false;
      _lastSync = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sync completed successfully!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _uploadToCloud() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Uploading to cloud...'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _downloadFromCloud() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Downloading from cloud...'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _clearSyncData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Sync Data'),
        content: const Text('This will remove all sync data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sync data cleared!'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
} 