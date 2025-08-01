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
      return status == 'pending' || status == 'inprogress' || status == 'in progress';
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
    // Always ensure sample orders exist for testing
    final now = DateTime.now();
    final sampleOrders = [
      {
        'id': 'SAMPLE-DINE-IN',
        'items': [
          {
            'id': 'item1',
            'name': 'Cappuccino',
            'price': 5.99,
            'quantity': 2,
            'comment': 'Extra hot',
            'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
          },
          {
            'id': 'item2',
            'name': 'Croissant',
            'price': 3.99,
            'quantity': 1,
            'comment': 'Warmed up',
            'imageUrl': 'https://images.unsplash.com/photo-1609501676725-7186f8b4beb8?w=200',
          },
        ],
        'totalAmount': 15.97,
        'status': 'inProgress',
        'createdAt': now.subtract(const Duration(minutes: 15)).toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'orderType': 'Dine-in',
        'tableNumber': '12',
      },
      {
        'id': 'SAMPLE-TAKEAWAY',
        'items': [
          {
            'id': 'item3',
            'name': 'Latte',
            'price': 4.99,
            'quantity': 1,
            'comment': 'Oat milk',
            'imageUrl': 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=200',
          },
          {
            'id': 'item4',
            'name': 'Chocolate Muffin',
            'price': 3.49,
            'quantity': 2,
            'imageUrl': 'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=200',
          },
        ],
        'totalAmount': 11.97,
        'status': 'pending',
        'createdAt': now.subtract(const Duration(minutes: 5)).toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'orderType': 'Takeaway',
        'customerName': 'Alex',
      },
    ];

    // Load existing orders but ensure samples are always present
    final existingOrders = MockService.getOrders();
    final nonSampleOrders = existingOrders.where(
      (order) => !order['id'].toString().startsWith('SAMPLE-')
    ).toList();

    state = [...sampleOrders, ...nonSampleOrders];
  }

  // Prevent deletion of sample orders
  Future<void> deleteOrder(String orderId) async {
    if (orderId.startsWith('SAMPLE-')) {
      // Don't allow deletion of sample orders
      return;
    }
    await MockService.deleteOrder(orderId);
    refreshOrders();
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
      return status == 'pending' || status == 'inprogress' || status == 'in progress';
    }).length;
  }
} 