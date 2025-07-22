import 'package:flutter/material.dart';
import 'package:vendura/core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = _featureCategories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Features'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _FeatureTile(category: cat);
        },
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final _FeatureCategory category;
  const _FeatureTile({required this.category});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(category.icon, color: category.color),
        title: Text(category.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: category.items
            .map((e) => ListTile(
                  title: Text(e),
                  dense: true,
                ))
            .toList(),
      ),
    );
  }
}

class _FeatureCategory {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;
  _FeatureCategory(this.title, this.items, this.icon, this.color);
}

final _featureCategories = <_FeatureCategory>[
  _FeatureCategory('Order Management', [
    'Smart Order Processing',
    'Add-ons Support',
    'Real-time Cart',
    'Professional UI',
  ], Icons.shopping_cart, Colors.blue),
  _FeatureCategory('Menu Management', [
    'Comprehensive Item Management',
    'Stock Management',
    'Add-ons System',
    'Category Organization',
  ], Icons.restaurant_menu, Colors.brown),
  _FeatureCategory('Settings & Configuration', [
    'Auto-Sync System',
    'Smart Feature Toggles',
    'Stock Alerts',
    'Receipt Settings',
    'Backup & Restore',
  ], Icons.settings, Colors.indigo),
  _FeatureCategory('Inventory Management', [
    'Real-time Stock Tracking',
    'Low Stock Alerts',
    'Stock Overview',
    'Minimum Stock Levels',
  ], Icons.inventory, Colors.orange),
]; 