import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/data/models/order.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/data/models/receipt.dart';
import 'package:vendura/core/services/receipt_generator.dart';
import 'package:vendura/core/providers/order_session_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedPaymentMethod = 'Card';
  double _totalAmount = 0.0;
  Order? _order;
  String _orderType = '';
  double _discountPercentage = 0.0;
  bool _isProcessing = false;
  // Tip disabled – always zero
  double _tip = 0.0;
  double _cashReceived = 0.0;
  double _change = 0.0;
  final TextEditingController _cashController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Card',
      'icon': Icons.credit_card,
      'description': 'Credit/Debit Card',
      'color': Colors.blue,
    },
    {
      'name': 'Cash',
      'icon': Icons.attach_money,
      'description': 'Cash Payment',
      'color': Colors.green,
    },
    {
      'name': 'PayNow/PayLah',
      'icon': Icons.payment,
      'description': 'Digital Payment',
      'color': Colors.purple,
    },
    {
      'name': 'Others',
      'icon': Icons.more_horiz,
      'description': 'Other Methods',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentData();
    });
  }

  @override
  void dispose() {
    // _tipController not used
    _cashController.dispose();
    super.dispose();
  }

  void _loadPaymentData() {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        _order = args['order'] as Order?;
        _totalAmount = args['totalAmount'] ?? 0.0;
        _orderType = args['orderType'] ?? '';
        _discountPercentage = args['discountPercentage'] ?? 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Total Amount Display (Top Center)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${_totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (_discountPercentage > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_discountPercentage.toStringAsFixed(0)}% Discount Applied',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Order Summary
            if (_order != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        const SizedBox(height: 8),
                        ..._order!.items.map((item) {
                          final lineTotal = item.price * item.quantity;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.quantity} x ${item.name}', style: const TextStyle(fontSize: 14)),
                                Text('\$${lineTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          );
                        }).toList(),
                        if (_discountPercentage > 0) ...[
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Discount (${_discountPercentage.toStringAsFixed(0)}%)', style: TextStyle(color: AppTheme.successGreen)),
                              Text('-\$${(_order!.items.fold(0.0, (s, i) => s + i.price * i.quantity) * (_discountPercentage / 100)).toStringAsFixed(2)}', style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                            Text('\$${_totalAmount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Payment Methods
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment Method Options
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _paymentMethods.length,
                        itemBuilder: (context, index) {
                          final method = _paymentMethods[index];
                          final isSelected = _selectedPaymentMethod == method['name'];
                          
                          return _buildPaymentMethodCard(method, isSelected);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Cash Input (if payment method is Cash)
            if (_selectedPaymentMethod == 'Cash')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Manual input row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        const Text('Cash Received', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _cashController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              border: OutlineInputBorder(),
                              prefixText: '  ',
                            ),
                            onChanged: (v) {
                              setState(() {
                                _cashReceived = double.tryParse(v) ?? 0.0;
                                final totalWithTip = _totalAmount + _tip;
                                _change = _cashReceived > totalWithTip ? _cashReceived - totalWithTip : 0.0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Change:  ${_change.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  // Quick select buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 8,
                      children: [2, 5, 10, 20, 50, 100, 'Other'].map((option) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: option is int ? AppTheme.primaryColor : Colors.grey[300],
                            foregroundColor: option is int ? Colors.white : Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            if (option is int) {
                              final amt = option.toDouble();
                              _cashController.text = amt.toStringAsFixed(2);
                              setState(() {
                                _cashReceived = amt;
                                final totalWithTip = _totalAmount + _tip;
                                _change = _cashReceived > totalWithTip ? _cashReceived - totalWithTip : 0.0;
                              });
                            } else {
                              // Clear for manual entry; maintain focus for numpad
                              _cashController.clear();
                              setState(() {
                                _cashReceived = 0.0;
                                _change = 0.0;
                              });
                              // Keep keyboard open for manual input
                            }
                          },
                          child: Text(
                            option is int ? '\$${option}' : 'Other',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            
            // Checkout Button
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Processing...'),
                          ],
                        )
                      : const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? method['color'] : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = method['name']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? method['color'].withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                method['icon'],
                size: 32,
                color: isSelected ? method['color'] : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                method['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? method['color'] : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                method['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: method['color'],
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      // Simulate payment success (90% success rate)
      final isSuccess = DateTime.now().millisecond % 10 != 0;
      
      if (isSuccess) {
        _showPaymentSuccess();
      } else {
        _showPaymentFailed();
      }
    }
  }

  void _showPaymentSuccess() async {
    // Generate receipt using ReceiptGenerator
    if (_order != null) {
      try {
        final amountPaid = _selectedPaymentMethod == 'Cash' ? _cashReceived : _totalAmount;
        final receiptId = await ReceiptGenerator.generateReceipt(
          order: _order!,
          paymentMethod: _mapPaymentMethodKey(_selectedPaymentMethod),
          amountPaid: amountPaid,
          tip: _tip,
          change: _change,
        );
        
        // Update receipts provider
        if (mounted) {
          ref.read(receiptsProvider.notifier).state = MockService.getReceipts();
          // Reset order session so OrderScreen clears
          ref.read(orderSessionProvider.notifier).state++;
        }
        
        // Show dialog and navigate to receipt
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successGreen, size: 28),
              const SizedBox(width: 8),
              const Text('Payment Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Amount:  ${_totalAmount.toStringAsFixed(2)}'),
              // Tip removed
              if (_selectedPaymentMethod == 'Cash') Text('Cash Received:  ${_cashReceived.toStringAsFixed(2)}'),
              if (_selectedPaymentMethod == 'Cash') Text('Change:  ${_change.toStringAsFixed(2)}'),
              Text('Method: $_selectedPaymentMethod'),
              Text('Order Type: $_orderType'),
              if (_discountPercentage > 0)
                Text('Discount: ${_discountPercentage.toStringAsFixed(0)}%'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _showSuccessNotification();
                _navigateToReceipt(receiptId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Receipt'),
            ),
          ],
        ),
      );
      } catch (e) {
        // Handle receipt generation error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating receipt: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _showPaymentFailed() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: AppTheme.errorRed, size: 28),
            const SizedBox(width: 8),
            const Text('Payment Failed'),
          ],
        ),
        content: const Text('Payment could not be processed. Please try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(); // Retry payment
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showSuccessNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Transaction successful!'),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _navigateToReceipt(String receiptId) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/receipt-detail',
      (route) => route.isFirst,
      arguments: {
        'receiptId': receiptId,
      },
    );
  }

  String _mapPaymentMethodKey(String method) {
    final lower = method.toLowerCase();
    if (lower.contains('cash')) return 'cash';
    if (lower.contains('card')) return 'card';
    if (lower.contains('paynow') || lower.contains('paylah')) return 'mobile';
    return 'mobile';
  }
} 