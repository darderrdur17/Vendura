import 'package:uuid/uuid.dart';

class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? imageUrl;
  final List<Map<String, dynamic>>? addOns;
  final String? comment; // Added comment field for special instructions

  const OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.imageUrl,
    this.addOns,
    this.comment,
  });

  // Create from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String?,
      addOns: json['addOns'] != null 
          ? List<Map<String, dynamic>>.from(json['addOns'] as List)
          : null,
      comment: json['comment'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'addOns': addOns,
      'comment': comment,
    };
  }

  // Copy with modifications
  OrderItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    List<Map<String, dynamic>>? addOns,
    String? comment,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      addOns: addOns ?? this.addOns,
      comment: comment ?? this.comment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum OrderStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  paid,
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? orderType; // Dine-in or Takeaway
  final double? discountPercentage; // Discount percentage applied
  final String? discountName; // Name of the discount applied

  const Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.orderType,
    this.discountPercentage,
    this.discountName,
  });

  Order copyWith({
    String? id,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? orderType,
    double? discountPercentage,
    String? discountName,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orderType: orderType ?? this.orderType,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountName: discountName ?? this.discountName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'orderType': orderType,
      'discountPercentage': discountPercentage,
      'discountName': discountName,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      orderType: json['orderType'] as String?,
      discountPercentage: json['discountPercentage'] as double?,
      discountName: json['discountName'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Order(id: $id, status: $status, totalAmount: $totalAmount)';
  }
} 