import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/core/providers/items_provider.dart';
import 'package:vendura/core/providers/settings_provider.dart';
import 'package:vendura/shared/presentation/widgets/animated_card.dart';

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  ConsumerState<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _showAvailableOnly = true;
  bool _showStockInfo = true;

  List<String> get categories => ['All', 'Coffee', 'Tea', 'Pastry', 'Food', 'Beverages', 'Specialty Coffee'];

  List<Map<String, dynamic>> get filteredItems {
    final items = ref.watch(availableItemsProvider);
    return items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesCategory = _selectedCategory == 'All' ||
          item['category'] == _selectedCategory;
      
      final matchesAvailability = !_showAvailableOnly || item['isAvailable'] == true;
      
      return matchesSearch && matchesCategory && matchesAvailability;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
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
                hintText: 'Search menu items...',
                prefixIcon: Icons.search,
                suffixIcon: _searchQuery.isNotEmpty ? Icons.clear : null,
                onSuffixPressed: _searchQuery.isNotEmpty
                    ? () => setState(() => _searchQuery = '')
                    : null,
              ),
            ),
          ),
          
          // Stock Overview
          Consumer(
            builder: (context, ref, child) {
              final stockAlertsEnabled = ref.watch(stockAlertsProvider);
              
              if (!stockAlertsEnabled) {
                return const SizedBox.shrink();
              }
              
              return Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStockCard(
                        'Low Stock',
                        ref.watch(lowStockItemsProvider).length.toString(),
                        AppTheme.warningOrange,
                        Icons.warning,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _buildStockCard(
                        'Out of Stock',
                        ref.watch(outOfStockItemsProvider).length.toString(),
                        AppTheme.errorRed,
                        Icons.cancel,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: _buildStockCard(
                        'Available',
                        filteredItems.length.toString(),
                        AppTheme.successGreen,
                        Icons.check_circle,
                      ),
                    ),
                  ],
                ),
              );
            },
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
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Menu Items List
          Expanded(
            child: filteredItems.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return AnimatedCard(
                        onTap: () => _editItem(item),
                        child: _buildMenuItemCard(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        heroTag: 'menu_fab',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenuItemCard(Map<String, dynamic> item) {
    final name = item['name'] as String;
    final category = item['category'] as String;
    final price = (item['price'] as num).toDouble();
    final description = item['description'] as String?;
    final isAvailable = item['isAvailable'] as bool? ?? true;
    final imageUrl = item['imageUrl'] as String?;
    final stockQuantity = item['stockQuantity'] ?? 0;
    final minStockLevel = item['minStockLevel'] ?? 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Item Image
            if (imageUrl != null)
              Container(
                width: 60,
                height: 60,
                margin: const EdgeInsets.only(right: AppTheme.spacingM),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          isAvailable ? 'Available' : 'Unavailable',
                          style: TextStyle(
                            color: isAvailable ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    category,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 8),
                  
                  // Stock Information
                  Consumer(
                    builder: (context, ref, child) {
                      final stockAlertsEnabled = ref.watch(stockAlertsProvider);
                      
                      if (!stockAlertsEnabled) {
                        return const SizedBox.shrink();
                      }
                      
                      return Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Stock: $stockQuantity',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (stockQuantity <= minStockLevel)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.warningOrange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Low Stock',
                                    style: TextStyle(
                                      color: AppTheme.warningOrange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  ),
                  
                  // Add-ons Count
                  if ((item['addOns'] as List<Map<String, dynamic>>? ?? []).isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.add_circle_outline, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${(item['addOns'] as List<Map<String, dynamic>>? ?? []).length} add-ons available',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${price.toStringAsFixed(2)}',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _manageStock(item),
                            icon: const Icon(Icons.inventory, size: 16),
                            tooltip: 'Manage Stock',
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.infoBlue.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => _manageAddOns(item),
                            icon: const Icon(Icons.add_circle_outline, size: 16),
                            tooltip: 'Manage Add-ons',
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => _editItem(item),
                            icon: const Icon(Icons.edit, size: 16),
                            tooltip: 'Edit',
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => _toggleAvailability(item),
                            icon: Icon(
                              isAvailable ? Icons.visibility_off : Icons.visibility,
                              size: 16,
                            ),
                            tooltip: isAvailable ? 'Hide Item' : 'Show Item',
                            style: IconButton.styleFrom(
                              backgroundColor: isAvailable 
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () => _deleteItem(item),
                            icon: const Icon(Icons.delete, size: 16),
                            tooltip: 'Delete',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
              Icons.menu_book,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'No menu items found',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Add items to start building your menu',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageCtrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              final data = {
                'name': nameCtrl.text.trim(),
                'price': price,
                'category': categoryCtrl.text.trim().isEmpty ? 'Uncategorized' : categoryCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'imageUrl': imageCtrl.text.trim(),
                'isAvailable': true,
              };
              await ref.read(itemsProvider.notifier).addItem(data);
              if (mounted) Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Available Only'),
              subtitle: const Text('Hide unavailable items'),
              value: _showAvailableOnly,
              onChanged: (value) {
                setState(() {
                  _showAvailableOnly = value;
                });
                Navigator.pop(context);
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
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
    final nameController = TextEditingController(text: item['name']);
    final priceController = TextEditingController(text: item['price'].toString());
    final categoryController = TextEditingController(text: item['category']);
    final descriptionController = TextEditingController(text: item['description'] ?? '');
    final imageUrlController = TextEditingController(text: item['imageUrl'] ?? '');
    bool isAvailable = item['isAvailable'] ?? true;
    int stockQuantity = item['stockQuantity'] ?? 0;
    int minStockLevel = item['minStockLevel'] ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Item: ${item['name']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Available'),
                    Switch(
                      value: isAvailable,
                      onChanged: (value) {
                        setDialogState(() => isAvailable = value);
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: stockQuantity.toString()),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock Quantity',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => stockQuantity = int.tryParse(v) ?? 0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: minStockLevel.toString()),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Min Stock',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => minStockLevel = int.tryParse(v) ?? 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedItem = {
                  ...item,
                  'name': nameController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'category': categoryController.text,
                  'description': descriptionController.text,
                  'imageUrl': imageUrlController.text,
                  'isAvailable': isAvailable,
                  'stockQuantity': stockQuantity,
                  'minStockLevel': minStockLevel,
                };
                await ref.read(itemsProvider.notifier).updateItem(item['id'], updatedItem);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Item "${nameController.text}" updated'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              },
              style: AppTheme.primaryButtonStyle,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAvailability(Map<String, dynamic> item) async {
    final newStatus = !(item['isAvailable'] as bool? ?? true);
    await ref.read(itemsProvider.notifier).updateItemAvailability(item['id'], newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} is now ${newStatus ? 'available' : 'unavailable'}'),
        backgroundColor: newStatus ? AppTheme.successGreen : AppTheme.warningOrange,
      ),
    );
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(itemsProvider.notifier).deleteItem(item['id']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item['name']} deleted'),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            count,
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _manageStock(Map<String, dynamic> item) {
    final currentStock = item['stockQuantity'] as int? ?? 0;
    final minStock = item['minStockLevel'] as int? ?? 0;
    final stockController = TextEditingController(text: currentStock.toString());
    final minStockController = TextEditingController(text: minStock.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Stock - ${item['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current stock info
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Stock:', style: AppTheme.bodyMedium),
                      Text(
                        '$currentStock',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: currentStock <= minStock ? AppTheme.warningOrange : AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Minimum Level:', style: AppTheme.bodyMedium),
                      Text('$minStock', style: AppTheme.bodyMedium),
                    ],
                  ),
                  if (currentStock <= minStock) ...[
                    const SizedBox(height: AppTheme.spacingS),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 16, color: AppTheme.warningOrange),
                          const SizedBox(width: 4),
                          Text(
                            'Low Stock Alert',
                            style: TextStyle(
                              color: AppTheme.warningOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Stock quantity input
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Stock Quantity',
                border: OutlineInputBorder(),
                helperText: 'Enter the new stock quantity',
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            
            // Minimum stock level input
            TextField(
              controller: minStockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minimum Stock Level',
                border: OutlineInputBorder(),
                helperText: 'Alert when stock falls below this level',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newQuantity = int.tryParse(stockController.text) ?? 0;
              final newMinLevel = int.tryParse(minStockController.text) ?? 0;
              
              if (newQuantity < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Stock quantity cannot be negative'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              // Update stock quantity
              await ref.read(itemsProvider.notifier).updateItemStock(item['id'], newQuantity);
              
              // Update minimum stock level (this would need to be added to the service)
              // For now, we'll just show success message
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Stock updated for ${item['name']}: $newQuantity units'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Update Stock'),
          ),
        ],
      ),
    );
  }

  void _manageAddOns(Map<String, dynamic> item) {
    final addOns = item['addOns'] as List<Map<String, dynamic>>? ?? [];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage Add-ons - ${item['name']}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add-ons (${addOns.length})'),
                  ElevatedButton.icon(
                    onPressed: () => _addNewAddOn(item),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: AppTheme.primaryButtonStyle,
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              Expanded(
                child: addOns.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              'No add-ons yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Text(
                              'Add customizations for this item',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: addOns.length,
                        itemBuilder: (context, index) {
                          final addOn = addOns[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                addOn['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('\$${addOn['price']} - ${addOn['category']}'),
                                  Row(
                                    children: [
                                      Icon(
                                        addOn['isAvailable'] == true 
                                            ? Icons.check_circle 
                                            : Icons.cancel,
                                        size: 16,
                                        color: addOn['isAvailable'] == true 
                                            ? AppTheme.successGreen 
                                            : AppTheme.errorRed,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        addOn['isAvailable'] == true ? 'Available' : 'Unavailable',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: addOn['isAvailable'] == true 
                                              ? AppTheme.successGreen 
                                              : AppTheme.errorRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Switch(
                                    value: addOn['isAvailable'] ?? true,
                                    onChanged: (value) async {
                                      await ref.read(itemsProvider.notifier).updateAddOn(
                                        item['id'],
                                        addOn['id'],
                                        {'isAvailable': value}
                                      );
                                    },
                                    activeColor: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () => _editAddOn(item, addOn),
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteAddOn(item, addOn),
                                    icon: const Icon(Icons.delete),
                                    tooltip: 'Delete',
                                    color: AppTheme.errorRed,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
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

  void _addNewAddOn(Map<String, dynamic> item) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedCategory = 'Coffee Add-ons';
    
    final categories = [
      'Coffee Add-ons',
      'Syrups',
      'Milk Substitutes',
      'Milk Add-ons',
      'Food Add-ons',
      'Toppings',
      'Sweeteners',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Add-on for ${item['name']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Add-on Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (\$)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: AppTheme.spacingM),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final addOnData = {
                  'id': 'addon-${DateTime.now().millisecondsSinceEpoch}',
                  'name': nameController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'category': selectedCategory,
                  'isAvailable': true,
                  'quantity': int.tryParse(quantityController.text) ?? 1,
                };
                
                await ref.read(itemsProvider.notifier).addAddOnToItem(item['id'], addOnData);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Add-on "${nameController.text}" added successfully'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editAddOn(Map<String, dynamic> item, Map<String, dynamic> addOn) {
    final nameController = TextEditingController(text: addOn['name']);
    final priceController = TextEditingController(text: addOn['price'].toString());
    final quantityController = TextEditingController(text: addOn['quantity'].toString());
    String selectedCategory = addOn['category'] ?? 'Coffee Add-ons';
    bool isAvailable = addOn['isAvailable'] ?? true;
    
    final categories = [
      'Coffee Add-ons',
      'Syrups',
      'Milk Substitutes',
      'Milk Add-ons',
      'Food Add-ons',
      'Toppings',
      'Sweeteners',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Add-on: ${addOn['name']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Add-on Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (\$)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),
                SwitchListTile(
                  title: const Text('Available'),
                  subtitle: const Text('Show this add-on to customers'),
                  value: isAvailable,
                  onChanged: (value) {
                    setDialogState(() {
                      isAvailable = value;
                    });
                  },
                  activeColor: AppTheme.primaryColor,
                ),
                const SizedBox(height: AppTheme.spacingM),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  final updatedAddOnData = {
                    'name': nameController.text,
                    'price': double.tryParse(priceController.text) ?? 0.0,
                    'category': selectedCategory,
                    'isAvailable': isAvailable,
                    'quantity': int.tryParse(quantityController.text) ?? 1,
                  };
                  
                  await ref.read(itemsProvider.notifier).updateAddOn(
                    item['id'], 
                    addOn['id'], 
                    updatedAddOnData
                  );
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Add-on "${nameController.text}" updated successfully'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              },
              style: AppTheme.primaryButtonStyle,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAddOn(Map<String, dynamic> item, Map<String, dynamic> addOn) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Add-on'),
        content: Text('Are you sure you want to delete "${addOn['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(itemsProvider.notifier).removeAddOnFromItem(
                item['id'],
                addOn['id']
              );
              Navigator.pop(context);
              Navigator.pop(context); // Close the manage add-ons dialog too
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Add-on "${addOn['name']}" deleted successfully'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showInlineEditDialog(Map<String, dynamic> item, String field, int currentValue) {
    final controller = TextEditingController(text: currentValue.toString());
    final label = field == 'stockQuantity' ? 'Stock Quantity' : 'Minimum Stock Level';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = int.tryParse(controller.text) ?? currentValue;
              Navigator.pop(context);
              final updatedItem = {
                ...item,
                field: newValue,
              };
              await ref.read(itemsProvider.notifier).updateItem(item['id'], updatedItem);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label updated for ${item['name']}'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 