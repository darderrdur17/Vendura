import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/data/models/order.dart';
import 'package:vendura/data/models/receipt.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String? orderId;
  final double? totalAmount;
  final Order? order;

  const PaymentScreen({
    super.key,
    this.orderId,
    this.totalAmount,
    this.order,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  double _amountPaid = 0.0;
  double _tipAmount = 0.0;
  bool _isProcessing = false;
  List<PaymentSplit> _paymentSplits = [];
  late TextEditingController _tipController;
  late TextEditingController _amountController;
  
  late Order _order;
  late double _totalAmount;

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _order = widget.order!;
      _totalAmount = widget.totalAmount ?? _order.totalAmount;
    } else {
      // Create a mock order for testing
      _order = Order(
        id: widget.orderId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        items: [],
        totalAmount: widget.totalAmount ?? 0.0,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _totalAmount = widget.totalAmount ?? 0.0;
    }
    _amountPaid = _totalAmount;
    _tipController = TextEditingController(text: _tipAmount.toStringAsFixed(2));
    _amountController = TextEditingController(text: _amountPaid.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _tipController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _finalTotal => _totalAmount + _tipAmount;
  double get _change => _amountPaid - _finalTotal;
  bool get _isValidPayment => _amountPaid >= _finalTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            _buildOrderSummary(),
            const SizedBox(height: 24),
            
            // Payment Method Selection
            _buildPaymentMethodSelection(),
            const SizedBox(height: 24),
            
            // Amount Input
            _buildAmountInput(),
            const SizedBox(height: 24),
            
            // Tip Section
            _buildTipSection(),
            const SizedBox(height: 24),
            
            // Split Payment (if multiple methods)
            if (_paymentSplits.isNotEmpty) _buildSplitPayment(),
            const SizedBox(height: 24),
            
            // Payment Summary
            _buildPaymentSummary(),
            const SizedBox(height: 32),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('\$${_totalAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tip:'),
                Text('\$${_tipAmount.toStringAsFixed(2)}'),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_finalTotal.toStringAsFixed(2)}',
                  style: AppTheme.titleMedium.copyWith(
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

  Widget _buildPaymentMethodSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Payment Method',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: PaymentMethod.values.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return ChoiceChip(
                  label: Text(method.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPaymentMethod = method;
                      if (method == PaymentMethod.split) {
                        _paymentSplits = [
                          PaymentSplit(PaymentMethod.cash, _finalTotal / 2),
                          PaymentSplit(PaymentMethod.card, _finalTotal / 2),
                        ];
                      } else {
                        _paymentSplits.clear();
                      }
                      
                      // Update amount paid based on payment method
                      if (method == PaymentMethod.cash) {
                        _amountPaid = _finalTotal;
                        _amountController.text = _amountPaid.toStringAsFixed(2);
                      } else if (method == PaymentMethod.card || method == PaymentMethod.mobile) {
                        _amountPaid = _finalTotal;
                        _amountController.text = _amountPaid.toStringAsFixed(2);
                      }
                    });
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.attach_money, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Amount Paid',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _amountPaid = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            if (_selectedPaymentMethod == PaymentMethod.cash && _change > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Change: \$${_change.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Tip',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // No Tip option
                      ChoiceChip(
                        label: const Text('No Tip'),
                        selected: _tipAmount == 0.0,
                        onSelected: (selected) {
                          setState(() {
                            _tipAmount = 0.0;
                            _tipController.text = _tipAmount.toStringAsFixed(2);
                            // Update amount paid to cover the new total
                            if (_selectedPaymentMethod == PaymentMethod.cash) {
                              _amountPaid = _finalTotal;
                              _amountController.text = _amountPaid.toStringAsFixed(2);
                            }
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: _tipAmount == 0.0 ? Colors.white : Colors.black87,
                        ),
                      ),
                      // Percentage options
                      ...([10, 15, 18, 20].map((percentage) {
                        final tipAmount = _totalAmount * (percentage / 100);
                        final isSelected = _tipAmount == tipAmount;
                        return ChoiceChip(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('$percentage%'),
                              Text(
                                '\$${tipAmount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? Colors.white70 : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          selected: isSelected,
                                                  onSelected: (selected) {
                          setState(() {
                            _tipAmount = tipAmount;
                            _tipController.text = _tipAmount.toStringAsFixed(2);
                            // Update amount paid to cover the new total
                            if (_selectedPaymentMethod == PaymentMethod.cash) {
                              _amountPaid = _finalTotal;
                              _amountController.text = _amountPaid.toStringAsFixed(2);
                            }
                          });
                        },
                          backgroundColor: Colors.grey[200],
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        );
                      })),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tipController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Custom Tip Amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _tipAmount = double.tryParse(value) ?? 0.0;
                  // Update amount paid to cover the new total
                  if (_selectedPaymentMethod == PaymentMethod.cash) {
                    _amountPaid = _finalTotal;
                    _amountController.text = _amountPaid.toStringAsFixed(2);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitPayment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Split Payment',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_paymentSplits.asMap().entries.map((entry) {
              final index = entry.key;
              final split = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<PaymentMethod>(
                        value: split.method,
                        decoration: InputDecoration(
                          labelText: 'Method ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: PaymentMethod.values
                            .where((method) => method != PaymentMethod.split)
                            .map((method) => DropdownMenuItem(
                                  value: method,
                                  child: Text(method.displayName),
                                ))
                            .toList(),
                        onChanged: (method) {
                          if (method != null) {
                            setState(() {
                              _paymentSplits[index] = PaymentSplit(method, split.amount);
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _paymentSplits[index] = PaymentSplit(
                              split.method,
                              double.tryParse(value) ?? 0.0,
                            );
                          });
                        },
                        controller: TextEditingController(
                          text: split.amount.toStringAsFixed(2),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Payment Summary',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal:'),
                Text('\$${_totalAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tip:'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('\$${_tipAmount.toStringAsFixed(2)}'),
                    if (_tipAmount > 0)
                      Text(
                        '(${((_tipAmount / _totalAmount) * 100).toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payment Method:'),
                Text(_selectedPaymentMethod.displayName),
              ],
            ),
            if (_selectedPaymentMethod == PaymentMethod.cash) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount Paid:'),
                  Text('\$${_amountPaid.toStringAsFixed(2)}'),
                ],
              ),
              if (_change > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Change:'),
                    Text(
                      '\$${_change.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${_finalTotal.toStringAsFixed(2)}',
                  style: AppTheme.titleMedium.copyWith(
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isValidPayment && !_isProcessing ? _processPayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Complete Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Create receipt
      final receipt = Receipt(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderId: _order.id,
        items: _order.items,
        subtotal: _totalAmount,
        tip: _tipAmount,
        total: _finalTotal,
        paymentMethod: _selectedPaymentMethod,
        amountPaid: _amountPaid,
        change: _change,
        createdAt: DateTime.now(),
      );

      // Save receipt
      await MockService.addReceipt(receipt.toJson());

      // Update order status
      final updatedOrder = _order.copyWith(
        status: OrderStatus.completed,
        totalAmount: _finalTotal,
      );
      await MockService.updateOrder(_order.id, updatedOrder.toJson());

      // Refresh providers to update UI
      ref.read(receiptsProvider.notifier).state = MockService.getReceipts();
      ref.read(ordersProvider.notifier).state = MockService.getOrders();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment completed successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Receipt',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/receipts',
                  arguments: {'receiptId': receipt.id},
                );
              },
            ),
          ),
        );

        // Navigate back to orders
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

// PaymentMethod is defined in receipt.dart

class PaymentSplit {
  PaymentMethod method;
  double amount;

  PaymentSplit(this.method, this.amount);
} 