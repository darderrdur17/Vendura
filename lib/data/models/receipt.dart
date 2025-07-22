import 'package:uuid/uuid.dart';
import 'package:vendura/data/models/order.dart';

enum PaymentMethod {
  cash('Cash'),
  card('Card'),
  mobile('Mobile Payment'),
  split('Split Payment');

  const PaymentMethod(this.displayName);
  final String displayName;
}

class Receipt {
  final String id;
  final String orderId;
  final List<OrderItem> items;
  final double subtotal;
  final double tip;
  final double total;
  final PaymentMethod paymentMethod;
  final double amountPaid;
  final double change;
  final DateTime createdAt;

  const Receipt({
    required this.id,
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.tip,
    required this.total,
    required this.paymentMethod,
    required this.amountPaid,
    required this.change,
    required this.createdAt,
  });

  // Create from JSON
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      tip: (json['tip'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paymentMethod: _parsePaymentMethod(json['paymentMethod'] as String),
      amountPaid: (json['amountPaid'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tip': tip,
      'total': total,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'amountPaid': amountPaid,
      'change': change,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with modifications
  Receipt copyWith({
    String? id,
    String? orderId,
    List<OrderItem>? items,
    double? subtotal,
    double? tip,
    double? total,
    PaymentMethod? paymentMethod,
    double? amountPaid,
    double? change,
    DateTime? createdAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tip: tip ?? this.tip,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      change: change ?? this.change,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Receipt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper to safely parse payment method
  static PaymentMethod _parsePaymentMethod(String method) {
    try {
      return PaymentMethod.values.firstWhere(
        (e) => e.name.toLowerCase() == method.toLowerCase(),
      );
    } catch (_) {
      // Map common mobile payment strings
      final normalized = method.toLowerCase();
      if (normalized.contains('paynow') || normalized.contains('paylah')) {
        return PaymentMethod.mobile;
      }
      if (normalized.contains('card')) return PaymentMethod.card;
      if (normalized.contains('cash')) return PaymentMethod.cash;
      return PaymentMethod.mobile;
    }
  }

  @override
  String toString() {
    return 'Receipt(id: $id, total: $total)';
  }
} 