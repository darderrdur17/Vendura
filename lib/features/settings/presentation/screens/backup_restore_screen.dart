import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _autoBackupEnabled = true;
  String _backupFrequency = 'Daily';
  String _backupLocation = 'Cloud';
  DateTime _lastBackup = DateTime.now().subtract(const Duration(hours: 2));
  double _backupProgress = 0.0;
  bool _isBackingUp = false;

  final List<String> _backupFrequencies = ['Daily', 'Weekly', 'Monthly'];
  final List<String> _backupLocations = ['Cloud', 'Local Storage', 'External Drive'];

  final List<Map<String, dynamic>> _backupHistory = [
    {
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'type': 'Automatic',
      'size': '2.4 MB',
      'status': 'Completed',
      'location': 'Cloud',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'Manual',
      'size': '2.3 MB',
      'status': 'Completed',
      'location': 'Cloud',
    },
    {
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'Automatic',
      'size': '2.2 MB',
      'status': 'Completed',
      'location': 'Cloud',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _createBackup,
            icon: const Icon(Icons.backup),
            tooltip: 'Create Backup',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.backup,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Backup',
                              style: AppTheme.titleSmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _formatDateTime(_lastBackup),
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
                          'Up to date',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isBackingUp) ...[
                    const SizedBox(height: AppTheme.spacingM),
                    LinearProgressIndicator(
                      value: _backupProgress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Backing up... ${(_backupProgress * 100).toInt()}%',
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Backup Settings
            _buildSectionHeader('Backup Settings', Icons.settings),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Automatic Backup'),
                    subtitle: const Text('Enable automatic backups'),
                    value: _autoBackupEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoBackupEnabled = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  if (_autoBackupEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Backup Frequency'),
                      subtitle: Text(_backupFrequency),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showFrequencyDialog(),
                    ),
                    
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Backup Location'),
                      subtitle: Text(_backupLocation),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showLocationDialog(),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Manual Backup
            _buildSectionHeader('Manual Backup', Icons.backup),
            const SizedBox(height: AppTheme.spacingM),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isBackingUp ? null : _createBackup,
                    icon: const Icon(Icons.backup),
                    label: const Text('Create Backup'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restoreBackup,
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore'),
                    style: AppTheme.secondaryButtonStyle,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Export/Import
            _buildSectionHeader('Export & Import', Icons.file_download),
            const SizedBox(height: AppTheme.spacingM),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exportData,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export Data'),
                    style: AppTheme.secondaryButtonStyle,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _importData,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Import Data'),
                    style: AppTheme.secondaryButtonStyle,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Backup History
            _buildSectionHeader('Backup History', Icons.history),
            const SizedBox(height: AppTheme.spacingM),
            
            ..._backupHistory.map((backup) => _buildBackupHistoryCard(backup)).toList(),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Data Management
            _buildSectionHeader('Data Management', Icons.storage),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_sweep, color: Colors.orange),
                    title: const Text('Clear Cache'),
                    subtitle: const Text('Free up storage space'),
                    onTap: _clearCache,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('Clear All Data'),
                    subtitle: const Text('Permanently delete all data'),
                    onTap: _clearAllData,
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

  Widget _buildBackupHistoryCard(Map<String, dynamic> backup) {
    final date = backup['date'] as DateTime;
    final type = backup['type'] as String;
    final size = backup['size'] as String;
    final status = backup['status'] as String;
    final location = backup['location'] as String;
    
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
            type == 'Automatic' ? Icons.schedule : Icons.backup,
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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDateTime(date)),
            Text('$size • $location'),
          ],
        ),
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
        onTap: () => _viewBackupDetails(backup),
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
        title: const Text('Backup Frequency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _backupFrequencies.map((frequency) {
            return RadioListTile<String>(
              title: Text(frequency),
              value: frequency,
              groupValue: _backupFrequency,
              onChanged: (value) {
                setState(() {
                  _backupFrequency = value!;
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

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _backupLocations.map((location) {
            return RadioListTile<String>(
              title: Text(location),
              value: location,
              groupValue: _backupLocation,
              onChanged: (value) {
                setState(() {
                  _backupLocation = value!;
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

  void _createBackup() async {
    setState(() {
      _isBackingUp = true;
      _backupProgress = 0.0;
    });

    // Simulate backup process
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        _backupProgress = i / 100;
      });
    }

    setState(() {
      _isBackingUp = false;
      _lastBackup = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Backup completed successfully!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _restoreBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text('Are you sure you want to restore from backup? This will replace all current data.'),
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
                  content: const Text('Backup restored successfully!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting data...'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Importing data...'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _viewBackupDetails(Map<String, dynamic> backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${_formatDateTime(backup['date'])}'),
            Text('Type: ${backup['type']}'),
            Text('Size: ${backup['size']}'),
            Text('Status: ${backup['status']}'),
            Text('Location: ${backup['location']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will free up storage space. Are you sure?'),
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
                  content: const Text('Cache cleared successfully!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will permanently delete all data. This action cannot be undone. Are you sure?'),
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
                  content: const Text('All data cleared!'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
} 