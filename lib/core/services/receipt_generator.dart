import 'package:vendura/data/models/order.dart';
import 'package:vendura/data/models/receipt.dart';
import 'package:vendura/data/models/receipt_config.dart';
import 'package:vendura/core/services/mock_service.dart';

class ReceiptGenerator {
  static const ReceiptConfig _defaultConfig = ReceiptConfig();

  /// Generates a receipt from an order
  static Future<String> generateReceipt({
    required Order order,
    required String paymentMethod,
    required double amountPaid,
    double tip = 0.0,
    double change = 0.0,
    ReceiptConfig? config,
  }) async {
    try {
      // Validate input
      if (order.items.isEmpty) {
        throw Exception('Cannot generate receipt: Order has no items');
      }

      if (amountPaid < 0) {
        throw Exception('Cannot generate receipt: Invalid amount paid');
      }

      // Calculate totals
      final subtotal = order.totalAmount;
      final totalWithTip = subtotal + tip;
      final actualChange = amountPaid > totalWithTip ? amountPaid - totalWithTip : 0.0;

      // Create receipt data
      final receiptData = {
        'orderId': order.id,
        'items': order.items.map((item) => {
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'imageUrl': item.imageUrl,
          'addOns': item.addOns ?? [],
          'comment': item.comment,
        }).toList(),
        'subtotal': subtotal,
        'tip': tip,
        'total': totalWithTip,
        'paymentMethod': paymentMethod.toLowerCase(),
        'amountPaid': amountPaid,
        'change': actualChange,
        'createdAt': DateTime.now().toIso8601String(),
        'orderType': order.orderType ?? 'Dine-in',
        'discountPercentage': order.discountPercentage ?? 0.0,
        'discountName': order.discountName,
      };

      // Generate receipt ID and save
      final receiptId = await MockService.addReceipt(receiptData);
      
      return receiptId;
    } catch (e) {
      throw Exception('Failed to generate receipt: $e');
    }
  }

  /// Creates a receipt object from order data (for preview)
  static Receipt createReceiptFromOrder({
    required Order order,
    required String paymentMethod,
    required double amountPaid,
    double tip = 0.0,
    String? receiptId,
  }) {
    final subtotal = order.totalAmount;
    final totalWithTip = subtotal + tip;
    final change = amountPaid > totalWithTip ? amountPaid - totalWithTip : 0.0;

    return Receipt(
      id: receiptId ?? 'preview-${DateTime.now().millisecondsSinceEpoch}',
      orderId: order.id,
      items: order.items,
      subtotal: subtotal,
      tip: tip,
      total: totalWithTip,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name.toLowerCase() == paymentMethod.toLowerCase(),
        orElse: () => PaymentMethod.cash,
      ),
      amountPaid: amountPaid,
      change: change,
      createdAt: DateTime.now(),
    );
  }

  /// Validates receipt data
  static bool validateReceiptData(Map<String, dynamic> receiptData) {
    final requiredFields = [
      'orderId',
      'items',
      'subtotal',
      'total',
      'paymentMethod',
      'amountPaid',
      'createdAt',
    ];

    for (final field in requiredFields) {
      if (!receiptData.containsKey(field) || receiptData[field] == null) {
        return false;
      }
    }

    // Validate items
    final items = receiptData['items'] as List?;
    if (items == null || items.isEmpty) {
      return false;
    }

    // Validate amounts
    final subtotal = receiptData['subtotal'] as num?;
    final total = receiptData['total'] as num?;
    final amountPaid = receiptData['amountPaid'] as num?;

    if (subtotal == null || subtotal < 0 ||
        total == null || total < 0 ||
        amountPaid == null || amountPaid < 0) {
      return false;
    }

    return true;
  }

  /// Gets receipt template configuration
  static ReceiptConfig getReceiptConfig() {
    // In a real app, this would come from settings/database
    return _defaultConfig;
  }

  /// Formats receipt for printing
  static String formatReceiptForPrint(Receipt receipt, {ReceiptConfig? config}) {
    final receiptConfig = config ?? _defaultConfig;
    final buffer = StringBuffer();

    // Header
    buffer.writeln('=' * 40);
    buffer.writeln(receiptConfig.cafeName.toUpperCase());
    if (receiptConfig.cafeSlogan.isNotEmpty) {
      buffer.writeln(receiptConfig.cafeSlogan);
    }
    if (receiptConfig.showContactInfo && receiptConfig.address.isNotEmpty) {
      buffer.writeln(receiptConfig.address);
    }
    buffer.writeln('=' * 40);

    // Receipt info
    buffer.writeln('Receipt #: ${receipt.id}');
    buffer.writeln('Order #: ${receipt.orderId}');
    buffer.writeln('Date: ${_formatDate(receipt.createdAt)}');
    buffer.writeln('Time: ${_formatTime(receipt.createdAt)}');
    buffer.writeln('-' * 40);

    // Items
    buffer.writeln('ITEMS:');
    for (final item in receipt.items) {
      buffer.writeln('${item.name} x${item.quantity}');
      buffer.writeln('  \$${item.price.toStringAsFixed(2)}');
      
      if (item.addOns != null && item.addOns!.isNotEmpty) {
        for (final addOn in item.addOns!) {
          buffer.writeln('  + ${addOn['name']} (\$${addOn['price']})');
        }
      }
      
      if (item.comment != null && item.comment!.isNotEmpty) {
        buffer.writeln('  Note: ${item.comment}');
      }
      buffer.writeln();
    }

    buffer.writeln('-' * 40);

    // Totals
    buffer.writeln('Subtotal: \$${receipt.subtotal.toStringAsFixed(2)}');
    if (receipt.tip > 0) {
      buffer.writeln('Tip: \$${receipt.tip.toStringAsFixed(2)}');
    }
    buffer.writeln('TOTAL: \$${receipt.total.toStringAsFixed(2)}');
    buffer.writeln();
    buffer.writeln('Payment: ${receipt.paymentMethod.displayName}');
    buffer.writeln('Amount Paid: \$${receipt.amountPaid.toStringAsFixed(2)}');
    if (receipt.change > 0) {
      buffer.writeln('Change: \$${receipt.change.toStringAsFixed(2)}');
    }

    buffer.writeln('=' * 40);
    
    // Footer
    if (receiptConfig.showThankYouMessage) {
      buffer.writeln(receiptConfig.receiptFooter);
    }

    return buffer.toString();
  }

  static String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  static String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 