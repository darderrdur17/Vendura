import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';

class AppDetailsScreen extends ConsumerWidget {
  const AppDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    child: const Icon(
                      Icons.coffee,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Vendura POS',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Version 1.0.0',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                ],
              ),
            ),
            
            // App Information
            _buildSectionHeader('App Information', Icons.info),
            const SizedBox(height: AppTheme.spacingM),
            
            _buildInfoCard(
              'Description',
              'A comprehensive Point of Sale system designed specifically for cafes and coffee shops. Manage orders, payments, inventory, and more.',
              Icons.description,
            ),
            
            _buildInfoCard(
              'Developer',
              'Vendura Development Team',
              Icons.person,
            ),
            
            _buildInfoCard(
              'Release Date',
              'December 2024',
              Icons.calendar_today,
            ),
            
            _buildInfoCard(
              'License',
              'Commercial License',
              Icons.verified,
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Features
            _buildSectionHeader('Features', Icons.star),
            const SizedBox(height: AppTheme.spacingM),
            
            _buildFeatureCard(
              'Order Management',
              'Create, edit, and track orders with real-time updates',
              Icons.shopping_cart,
              Colors.blue,
            ),
            
            _buildFeatureCard(
              'Payment Processing',
              'Multiple payment methods with secure processing',
              Icons.payment,
              Colors.green,
            ),
            
            _buildFeatureCard(
              'Inventory Management',
              'Track stock levels and manage inventory efficiently',
              Icons.inventory,
              Colors.orange,
            ),
            
            _buildFeatureCard(
              'Receipt Management',
              'Generate and manage digital receipts',
              Icons.receipt,
              Colors.purple,
            ),
            
            _buildFeatureCard(
              'Refund System',
              'Process refunds and exchanges seamlessly',
              Icons.money_off,
              Colors.red,
            ),
            
            _buildFeatureCard(
              'Reporting & Analytics',
              'Comprehensive reports and business insights',
              Icons.analytics,
              Colors.teal,
            ),

            _buildFeatureCard(
              'Menu Management',
              'Full CRUD operations and category organization',
              Icons.restaurant_menu,
              Colors.brown,
            ),

            _buildFeatureCard(
              'Settings & Configuration',
              'Auto-sync, feature toggles, backup & restore',
              Icons.settings,
              Colors.indigo,
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Technical Information
            _buildSectionHeader('Technical Information', Icons.engineering),
            const SizedBox(height: AppTheme.spacingM),
            
            _buildInfoCard(
              'Framework',
              'Flutter 3.16.0',
              Icons.code,
            ),
            
            _buildInfoCard(
              'Platform',
              'Cross-platform (iOS, Android, Web)',
              Icons.devices,
            ),
            
            _buildInfoCard(
              'Database',
              'Local SQLite + Cloud Sync',
              Icons.storage,
            ),
            
            _buildInfoCard(
              'Architecture',
              'Clean Architecture with Riverpod',
              Icons.architecture,
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // System Requirements
            _buildSectionHeader('System Requirements', Icons.computer),
            const SizedBox(height: AppTheme.spacingM),
            
            _buildInfoCard(
              'Operating System',
              'iOS 12+, Android 6+, Web browsers',
              Icons.phone_android,
            ),
            
            _buildInfoCard(
              'Storage',
              'Minimum 100MB free space',
              Icons.sd_storage,
            ),
            
            _buildInfoCard(
              'Memory',
              'Minimum 2GB RAM',
              Icons.memory,
            ),
            
            _buildInfoCard(
              'Network',
              'Internet connection for cloud features',
              Icons.wifi,
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _checkForUpdates(context),
                icon: const Icon(Icons.system_update),
                label: const Text('Check for Updates'),
                style: AppTheme.primaryButtonStyle,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _exportAppData(context),
                icon: const Icon(Icons.download),
                label: const Text('Export App Data'),
                style: AppTheme.secondaryButtonStyle,
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

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: AppTheme.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value,
          style: AppTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _checkForUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Checking for updates...'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _exportAppData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exporting app data...'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
} 