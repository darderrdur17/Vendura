import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/data/models/order.dart';
import 'package:vendura/core/providers/orders_provider.dart';

class OrdersListScreen extends ConsumerStatefulWidget {
  const OrdersListScreen({super.key});

  @override
  ConsumerState<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends ConsumerState<OrdersListScreen> {
  String _selectedStatus = 'All';

  List<String> get statusFilters => ['All', 'Pending', 'In Progress', 'Completed', 'Cancelled'];

  List<Map<String, dynamic>> get filteredOrders {
    final orders = ref.watch(ordersProvider);
    if (_selectedStatus == 'All') return orders;
    
    return orders.where((order) {
      final status = order['status'] as String;
      final selectedStatus = _selectedStatus.toLowerCase().replaceAll(' ', '');
      return status.toLowerCase() == selectedStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _createNewOrder(),
            icon: const Icon(Icons.add),
            tooltip: 'New Order',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Filter
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: statusFilters.length,
                itemBuilder: (context, index) {
                  final status = statusFilters[index];
                  final isSelected = status == _selectedStatus;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedStatus = status);
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppTheme.primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
      // Floating action button is handled by MainScreen
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first order to get started',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _createNewOrder(),
            icon: const Icon(Icons.add),
            label: const Text('Create New Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['id'] as String? ?? '';
    final status = order['status'] as String? ?? 'pending';
    final totalAmount = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final createdAt = DateTime.tryParse(order['createdAt'] as String? ?? '') ?? DateTime.now();
    final items = order['items'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppTheme.lightGray.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewOrder(order),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Order ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        orderId,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),
              
              const SizedBox(height: 12),
              
              // Order Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${items.length} items',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${_formatDateTime(createdAt)}',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusDescription(status),
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Quick Actions
              if (status == 'Pending' || status == 'In Progress')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editOrder(order),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _processPayment(order),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    String displayText;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'completed':
        chipColor = AppTheme.successGreen;
        textColor = Colors.white;
        displayText = 'Completed';
        icon = Icons.check_circle;
        break;
      case 'in progress':
        chipColor = AppTheme.warningOrange;
        textColor = Colors.white;
        displayText = 'In Progress';
        icon = Icons.pending;
        break;
      case 'pending':
        chipColor = AppTheme.infoBlue;
        textColor = Colors.white;
        displayText = 'Pending';
        icon = Icons.schedule;
        break;
      case 'cancelled':
        chipColor = AppTheme.errorRed;
        textColor = Colors.white;
        displayText = 'Cancelled';
        icon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey;
        textColor = Colors.white;
        displayText = status;
        icon = Icons.info;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: chipColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  String _getStatusDescription(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Waiting to be processed';
      case 'in progress':
        return 'Being prepared';
      case 'completed':
        return 'Order fulfilled';
      case 'cancelled':
        return 'Order cancelled';
      default:
        return 'Unknown status';
    }
  }

  void _createNewOrder() {
    Navigator.pushNamed(
      context,
      '/order',
      arguments: {
        'isNewOrder': true,
      },
    );
  }

  void _viewOrder(Map<String, dynamic> order) {
    final items = (order['items'] as List<dynamic>?) ?? [];
    final cart = items.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList();
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;

    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: {
        'cartItems': cart,
        'totalAmount': total,
        'readonly': true,
      },
    );
  }

  void _editOrder(Map<String, dynamic> order) {
    Navigator.pushNamed(
      context,
      '/order',
      arguments: {
        'orderId': order['id'],
        'isNewOrder': false,
      },
    );
  }

  void _processPayment(Map<String, dynamic> order) {
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'orderId': order['id'],
        'totalAmount': order['totalAmount'],
      },
    );
  }
} 