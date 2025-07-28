import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/services/mock_service.dart';


// Provider for all orders
final ordersProvider = StateNotifierProvider<OrdersNotifier, List<Map<String, dynamic>>>(
  (ref) => OrdersNotifier(),
);

// Provider for ongoing orders only (pending and in progress)
final ongoingOrdersProvider = Provider<List<Map<String, dynamic>>>(
  (ref) {
    final orders = ref.watch(ordersProvider);
    return orders.where((order) {
      final status = (order['status'] as String).toLowerCase();
      return status == 'pending' || status == 'in progress';
    }).toList();
  },
);

// Provider for completed orders
final completedOrdersProvider = Provider<List<Map<String, dynamic>>>(
  (ref) {
    final orders = ref.watch(ordersProvider);
    return orders.where((order) {
      final status = (order['status'] as String).toLowerCase();
      return status == 'completed' || status == 'paid';
    }).toList();
  },
);

class OrdersNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  OrdersNotifier() : super([]) {
    _loadOrders();
  }

  void _loadOrders() {
    state = MockService.getOrders();
  }

  // Refresh orders from service
  void refreshOrders() {
    state = MockService.getOrders();
  }

  // Add new order
  Future<String> addOrder(Map<String, dynamic> orderData) async {
    final orderId = await MockService.addOrder(orderData);
    refreshOrders();
    return orderId;
  }

  // Update order
  Future<void> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    await MockService.updateOrder(orderId, orderData);
    refreshOrders();
  }

  // Delete order
  Future<void> deleteOrder(String orderId) async {
    await MockService.deleteOrder(orderId);
    refreshOrders();
  }

  // Mark order as completed after successful payment
  Future<void> completeOrder(String orderId) async {
    print('Completing order: $orderId');
    final orderIndex = state.indexWhere((order) => order['id'] == orderId);
    print('Found order at index: $orderIndex');
    if (orderIndex != -1) {
      final updatedOrder = Map<String, dynamic>.from(state[orderIndex]);
      updatedOrder['status'] = 'completed';
      updatedOrder['updatedAt'] = DateTime.now().toIso8601String();
      
      print('Updating order status to completed');
      await MockService.updateOrder(orderId, updatedOrder);
      refreshOrders();
      print('Order completed successfully');
    } else {
      print('Order not found in state');
    }
  }

  // Cancel ongoing order
  Future<void> cancelOrder(String orderId) async {
    print('Cancelling order: $orderId');
    final orderIndex = state.indexWhere((order) => order['id'] == orderId);
    print('Found order at index: $orderIndex');
    if (orderIndex != -1) {
      final updatedOrder = Map<String, dynamic>.from(state[orderIndex]);
      updatedOrder['status'] = 'cancelled';
      updatedOrder['updatedAt'] = DateTime.now().toIso8601String();
      
      print('Updating order status to cancelled');
      await MockService.updateOrder(orderId, updatedOrder);
      refreshOrders();
      print('Order cancelled successfully');
    } else {
      print('Order not found in state');
    }
  }

  // Get order by ID
  Map<String, dynamic>? getOrder(String orderId) {
    try {
      return state.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }

  // Get ongoing orders count
  int get ongoingOrdersCount {
    return state.where((order) {
      final status = (order['status'] as String).toLowerCase();
      return status == 'pending' || status == 'in progress';
    }).length;
  }
} 