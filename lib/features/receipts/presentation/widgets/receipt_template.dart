import 'package:flutter/material.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/data/models/receipt.dart';
import 'package:vendura/data/models/receipt_config.dart';

class ReceiptTemplate extends StatelessWidget {
  final Receipt receipt;
  final ReceiptConfig? config;

  const ReceiptTemplate({
    super.key,
    required this.receipt,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    final receiptConfig = config ?? const ReceiptConfig();
    
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: receiptConfig.size.width),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Logo and Cafe Info
          _buildHeader(receiptConfig),
          const Divider(height: 24, thickness: 1),
          
          // Order Information
          _buildOrderInfo(),
          const SizedBox(height: 16),
          
          // Items List
          _buildItemsList(),
          const Divider(height: 16, thickness: 1),
          
          // Totals Section
          _buildTotalsSection(),
          const SizedBox(height: 16),
          
          // Payment Information
          _buildPaymentInfo(),
          const SizedBox(height: 16),
          
          // Footer
          _buildFooter(receiptConfig),
        ],
      ),
    );
  }

  Widget _buildHeader(ReceiptConfig receiptConfig) {
    return Column(
      children: [
        // Logo and Cafe Name
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.coffee,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                Text(
                  receiptConfig.cafeName,
                  style: TextStyle(
                    fontSize: receiptConfig.fontSize.header,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    letterSpacing: 1.2,
                  ),
                ),
                if (receiptConfig.cafeSlogan.isNotEmpty)
                  Text(
                    receiptConfig.cafeSlogan,
                    style: TextStyle(
                      fontSize: receiptConfig.fontSize.body,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Address and Contact
        if (receiptConfig.showContactInfo)
          Column(
            children: [
              if (receiptConfig.address.isNotEmpty)
                Text(
                  receiptConfig.address,
                  style: TextStyle(
                    fontSize: receiptConfig.fontSize.body,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              if (receiptConfig.phone.isNotEmpty || receiptConfig.email.isNotEmpty)
                Text(
                  [
                    if (receiptConfig.phone.isNotEmpty) 'Tel: ${receiptConfig.phone}',
                    if (receiptConfig.email.isNotEmpty) 'Email: ${receiptConfig.email}',
                  ].join(' | '),
                  style: TextStyle(
                    fontSize: receiptConfig.fontSize.detail,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt #${receipt.id.substring(receipt.id.length - 6)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Order #${receipt.orderId.substring(receipt.orderId.length - 6)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(receipt.createdAt),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatTime(receipt.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      children: [
        // Header row
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                'Item',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Qty',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Price',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              child: Text(
                'Total',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Items
        ...receipt.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.addOns != null && item.addOns!.isNotEmpty)
                          ...item.addOns!.map((addOn) => Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Text(
                              '  + ${addOn['name']} (\$${(addOn['price'] as num).toStringAsFixed(2)})',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          )),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${(item.price / item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (item.comment != null && item.comment!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    'Note: ${item.comment}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTotalsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '\$${receipt.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (receipt.tip > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tip:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '\$${receipt.tip.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              Text(
                '\$${receipt.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPaymentMethodColor(receipt.paymentMethod.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  receipt.paymentMethod.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getPaymentMethodColor(receipt.paymentMethod.name),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount Paid:',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '\$${receipt.amountPaid.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (receipt.change > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '\$${receipt.change.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooter(ReceiptConfig receiptConfig) {
    return Column(
      children: [
        const Divider(height: 16, thickness: 1),
        if (receiptConfig.showThankYouMessage) ...[
          Text(
            receiptConfig.receiptFooter,
            style: TextStyle(
              fontSize: receiptConfig.fontSize.body,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'We hope you enjoyed your experience',
            style: TextStyle(
              fontSize: receiptConfig.fontSize.detail,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Please visit us again soon',
            style: TextStyle(
              fontSize: receiptConfig.fontSize.detail,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Receipt ID: ${receipt.id}',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[400],
              ),
            ),
            Text(
              'Generated: ${_formatDateTime(receipt.createdAt)}',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'mobile':
        return Colors.purple;
      case 'split':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
} 