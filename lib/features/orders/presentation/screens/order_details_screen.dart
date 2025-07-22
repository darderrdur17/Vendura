import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/data/models/order.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  String _orderType = 'Dine-in'; // Dine-in or Takeaway
  String? _selectedDiscount;
  double _discountPercentage = 0.0;
  List<OrderItem> _cartItems = [];
  double _totalAmount = 0.0;

  // Discount options based on user's requirements
  final List<Map<String, dynamic>> _discountOptions = [
    {'name': 'Hospitality Worker Discount', 'percentage': 15.0, 'description': 'For hospitality industry workers'},
    {'name': 'Before 9 AM Discount', 'percentage': 20.0, 'description': 'Valid before 9:00 AM'},
    {'name': 'After 5 PM Pastries/Foods', 'percentage': 50.0, 'description': 'Pastries and foods after 5:00 PM'},
    {'name': 'Staff Discount', 'percentage': 30.0, 'description': 'For cafe staff members'},
    {'name': 'Usual Customer Discount', 'percentage': 15.0, 'description': 'For regular customers'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderData();
    });
  }

  void _loadOrderData() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _cartItems = List<OrderItem>.from(args['cartItems'] ?? []);
        _totalAmount = args['totalAmount'] ?? 0.0;
      });
    }
  }

  double get _subtotal => _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get _discountAmount => _subtotal * (_discountPercentage / 100);
  double get _finalTotal => _subtotal - _discountAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Type Selection
              _buildOrderTypeSection(),
              const SizedBox(height: 24),
              
              // Discount Section
              _buildDiscountSection(),
              const SizedBox(height: 24),
              
              // Order Summary
              _buildOrderSummary(),
              const SizedBox(height: 32),
              
              // Proceed to Payment Button
              _buildProceedButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOrderTypeOption(
                    'Dine-in',
                    Icons.restaurant,
                    'Eat at the cafe',
                    _orderType == 'Dine-in',
                    () => setState(() => _orderType = 'Dine-in'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOrderTypeOption(
                    'Takeaway',
                    Icons.takeout_dining,
                    'Take food to go',
                    _orderType == 'Takeaway',
                    () => setState(() => _orderType = 'Takeaway'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeOption(String title, IconData icon, String subtitle, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Discounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ..._discountOptions.map((discount) => _buildDiscountOption(discount)),
            const SizedBox(height: 12),
            if (_selectedDiscount != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Discount:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successGreen,
                    ),
                  ),
                  Text(
                    '${_discountPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountOption(Map<String, dynamic> discount) {
    final isSelected = _selectedDiscount == discount['name'];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppTheme.successGreen.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppTheme.successGreen : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected ? AppTheme.successGreen : Colors.grey[600],
        ),
        title: Text(
          discount['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppTheme.successGreen : Colors.black87,
          ),
        ),
        subtitle: Text(
          discount['description'],
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '${discount['percentage'].toStringAsFixed(0)}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isSelected ? AppTheme.successGreen : AppTheme.primaryColor,
          ),
        ),
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedDiscount = null;
              _discountPercentage = 0.0;
            } else {
              _selectedDiscount = discount['name'];
              _discountPercentage = discount['percentage'];
            }
          });
        },
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Order Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Type:', style: TextStyle(color: Colors.grey[600])),
                Text(_orderType, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            // Items list
            Column(
              children: _cartItems.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.name} x${item.quantity}')),
                    Text('•  \$${item.price.toStringAsFixed(2)}'),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal:', style: TextStyle(color: Colors.grey[600])),
                Text('\$${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            
            // Discount
            if (_discountPercentage > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Discount (${_discountPercentage.toStringAsFixed(0)}%):', 
                       style: TextStyle(color: AppTheme.successGreen)),
                  Text('-\$${_discountAmount.toStringAsFixed(2)}', 
                       style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            
            const Divider(),
            
            // Final Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  '\$${_finalTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Proceed to Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _proceedToPayment() {
    // Create order with all details
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: _cartItems,
      totalAmount: _finalTotal,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      orderType: _orderType,
      discountPercentage: _discountPercentage,
      discountName: _selectedDiscount,
    );

    // Navigate to payment screen
    Navigator.pushNamed(
      context,
      '/payment',
      arguments: {
        'order': order,
        'totalAmount': _finalTotal,
        'orderType': _orderType,
        'discountPercentage': _discountPercentage,
      },
    );
  }
} 