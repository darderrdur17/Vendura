import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/services/mock_service.dart';

// Provider for all menu items
final itemsProvider = StateNotifierProvider<ItemsNotifier, List<Map<String, dynamic>>>(
  (ref) => ItemsNotifier(),
);

// Provider for available items only (for order page)
final availableItemsProvider = Provider<List<Map<String, dynamic>>>(
  (ref) {
    final items = ref.watch(itemsProvider);
    return items.where((item) => item['isAvailable'] == true).toList();
  },
);

// Provider for items by category
final itemsByCategoryProvider = Provider.family<List<Map<String, dynamic>>, String>(
  (ref, category) {
    final items = ref.watch(itemsProvider);
    return items.where((item) => 
      item['category'] == category && item['isAvailable'] == true
    ).toList();
  },
);

// Provider for low stock items
final lowStockItemsProvider = Provider<List<Map<String, dynamic>>>(
  (ref) {
    return MockService.getLowStockItems();
  },
);

// Provider for out of stock items
final outOfStockItemsProvider = Provider<List<Map<String, dynamic>>>(
  (ref) {
    return MockService.getOutOfStockItems();
  },
);

class ItemsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ItemsNotifier() : super([]) {
    _loadItems();
  }

  void _loadItems() {
    state = MockService.getItems();
  }

  // Refresh items from service
  void refreshItems() {
    state = MockService.getItems();
  }

  // Update item availability
  Future<void> updateItemAvailability(String itemId, bool isAvailable) async {
    await MockService.setItemAvailability(itemId, isAvailable);
    refreshItems();
  }

  // Update item stock
  Future<void> updateItemStock(String itemId, int newQuantity) async {
    await MockService.updateItemStock(itemId, newQuantity);
    refreshItems();
  }

  // Add new add-on to item
  Future<void> addAddOnToItem(String itemId, Map<String, dynamic> addOnData) async {
    await MockService.addAddOnToItem(itemId, addOnData);
    refreshItems();
  }

  // Update add-on
  Future<void> updateAddOn(String itemId, String addOnId, Map<String, dynamic> addOnData) async {
    await MockService.updateAddOn(itemId, addOnId, addOnData);
    refreshItems();
  }

  // Remove add-on from item
  Future<void> removeAddOnFromItem(String itemId, String addOnId) async {
    await MockService.removeAddOnFromItem(itemId, addOnId);
    refreshItems();
  }

  // Get add-ons for specific item
  List<Map<String, dynamic>> getAddOnsForItem(String itemId) {
    return MockService.getAddOnsForItem(itemId);
  }

  // Get available add-ons for specific item
  List<Map<String, dynamic>> getAvailableAddOnsForItem(String itemId) {
    final allAddOns = MockService.getAddOnsForItem(itemId);
    return allAddOns.where((addon) => addon['isAvailable'] == true).toList();
  }
} 