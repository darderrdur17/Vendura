import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/services/mock_service.dart';

final inventoryProvider = StateNotifierProvider<InventoryNotifier, List<Map<String, dynamic>>>((ref) {
  return InventoryNotifier();
});

class InventoryNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  InventoryNotifier() : super(MockService.getItems());

  Future<void> refresh() async {
    state = MockService.getItems();
  }

  Future<void> addItem(Map<String, dynamic> item) async {
    await MockService.addItem(item);
    await refresh();
  }

  Future<void> updateItem(String id, Map<String, dynamic> item) async {
    await MockService.updateItem(id, item);
    await refresh();
  }

  Future<void> addAddOn(String itemId, Map<String, dynamic> addOn) async {
    await MockService.addAddOnToItem(itemId, addOn);
    await refresh();
  }
} 