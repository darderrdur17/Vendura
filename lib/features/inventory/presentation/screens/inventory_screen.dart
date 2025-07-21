import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/shared/presentation/widgets/animated_card.dart';
import 'package:vendura/shared/presentation/widgets/shimmer_loading.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedFilter = 'All';

  List<String> get categories => ['All', 'Coffee', 'Tea', 'Pastry', 'Food', 'Beverages'];
  List<String> get filterOptions => ['All', 'Low Stock', 'Out of Stock', 'Expiring Soon'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add Item',
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: AppTheme.searchInputDecoration(
                hintText: 'Search inventory...',
                prefixIcon: Icons.search,
                suffixIcon: _searchQuery.isNotEmpty ? Icons.clear : null,
                onSuffixPressed: _searchQuery.isNotEmpty
                    ? () => setState(() => _searchQuery = '')
                    : null,
              ),
            ),
          ),
          
          // Category Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacingS),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Inventory Summary Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Items',
                    '156',
                    Icons.inventory,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: _buildSummaryCard(
                    'Low Stock',
                    '8',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: _buildSummaryCard(
                    'Out of Stock',
                    '3',
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Inventory List
          Expanded(
            child: _buildInventoryList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: AppTheme.cardDecoration(elevated: true),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              value,
              style: AppTheme.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryList() {
    // Mock inventory data
    final inventoryItems = [
      {
        'id': 'inv-1',
        'name': 'Coffee Beans',
        'category': 'Coffee',
        'currentStock': 25.5,
        'minStock': 10.0,
        'unit': 'kg',
        'lastUpdated': DateTime.now().subtract(const Duration(hours: 2)),
        'status': 'normal',
      },
      {
        'id': 'inv-2',
        'name': 'Milk',
        'category': 'Beverages',
        'currentStock': 8.0,
        'minStock': 10.0,
        'unit': 'L',
        'lastUpdated': DateTime.now().subtract(const Duration(hours: 1)),
        'status': 'low',
      },
      {
        'id': 'inv-3',
        'name': 'Croissants',
        'category': 'Pastry',
        'currentStock': 0,
        'minStock': 5,
        'unit': 'pieces',
        'lastUpdated': DateTime.now().subtract(const Duration(minutes: 30)),
        'status': 'out',
      },
      {
        'id': 'inv-4',
        'name': 'Green Tea',
        'category': 'Tea',
        'currentStock': 15.0,
        'minStock': 5.0,
        'unit': 'boxes',
        'lastUpdated': DateTime.now().subtract(const Duration(hours: 3)),
        'status': 'normal',
      },
    ];

    final filteredItems = inventoryItems.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'All' ||
          item['category'] == _selectedCategory;
      
      final matchesFilter = _selectedFilter == 'All' ||
          (_selectedFilter == 'Low Stock' && item['status'] == 'low') ||
          (_selectedFilter == 'Out of Stock' && item['status'] == 'out');
      
      return matchesSearch && matchesCategory && matchesFilter;
    }).toList();

    if (filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return AnimatedCard(
          onTap: () => _editItem(item),
          child: _buildInventoryCard(item),
        );
      },
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final category = item['category'] as String;
    final currentStock = (item['currentStock'] as num).toDouble();
    final minStock = (item['minStock'] as num).toDouble();
    final unit = item['unit'] as String;
    final status = item['status'] as String;
    final lastUpdated = item['lastUpdated'] as DateTime;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        category,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Stock',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${currentStock.toStringAsFixed(1)} $unit',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getStockColor(currentStock, minStock),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Min Stock',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${minStock.toStringAsFixed(1)} $unit',
                        style: AppTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Updated',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _formatDateTime(lastUpdated),
                        style: AppTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _adjustStock(item),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Adjust'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewHistory(item),
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('History'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reorderItem(item),
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Reorder'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'No inventory items found',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Add items to start tracking inventory',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'normal':
        return Colors.green;
      case 'low':
        return Colors.orange;
      case 'out':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'normal':
        return 'IN STOCK';
      case 'low':
        return 'LOW STOCK';
      case 'out':
        return 'OUT OF STOCK';
      default:
        return 'UNKNOWN';
    }
  }

  Color _getStockColor(double current, double min) {
    if (current <= 0) return Colors.red;
    if (current <= min) return Colors.orange;
    return Colors.green;
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

  void _showAddItemDialog() {
    // TODO: Implement add item dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add item functionality coming soon'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Inventory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: filterOptions.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
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

  void _editItem(Map<String, dynamic> item) {
    // TODO: Implement edit item
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing ${item['name']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _adjustStock(Map<String, dynamic> item) {
    // TODO: Implement stock adjustment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Adjusting stock for ${item['name']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _viewHistory(Map<String, dynamic> item) {
    // TODO: Implement history view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing history for ${item['name']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _reorderItem(Map<String, dynamic> item) {
    // TODO: Implement reorder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating reorder for ${item['name']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 