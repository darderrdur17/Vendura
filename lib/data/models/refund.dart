import 'package:uuid/uuid.dart';

enum RefundStatus {
  pending,
  approved,
  completed,
  rejected,
}

enum RefundType {
  full,
  partial,
  exchange,
}

enum RefundReason {
  customerRequest,
  wrongItem,
  qualityIssue,
  duplicateCharge,
  systemError,
  other,
}

class Refund {
  final String id;
  final String receiptId;
  final String orderId;
  final RefundType type;
  final RefundStatus status;
  final RefundReason reason;
  final String? description;
  final double originalAmount;
  final double refundAmount;
  final List<RefundItem> items;
  final String processedBy;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? notes;

  const Refund({
    required this.id,
    required this.receiptId,
    required this.orderId,
    required this.type,
    required this.status,
    required this.reason,
    this.description,
    required this.originalAmount,
    required this.refundAmount,
    required this.items,
    required this.processedBy,
    required this.createdAt,
    this.processedAt,
    this.notes,
  });

  // Create a new refund
  factory Refund.create({
    required String receiptId,
    required String orderId,
    required RefundType type,
    required RefundReason reason,
    String? description,
    required double originalAmount,
    required double refundAmount,
    required List<RefundItem> items,
    required String processedBy,
    String? notes,
  }) {
    final now = DateTime.now();
    return Refund(
      id: const Uuid().v4(),
      receiptId: receiptId,
      orderId: orderId,
      type: type,
      status: RefundStatus.pending,
      reason: reason,
      description: description,
      originalAmount: originalAmount,
      refundAmount: refundAmount,
      items: items,
      processedBy: processedBy,
      createdAt: now,
      notes: notes,
    );
  }

  // Create from JSON
  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'] as String,
      receiptId: json['receiptId'] as String,
      orderId: json['orderId'] as String,
      type: RefundType.values.firstWhere(
        (e) => e.toString() == 'RefundType.${json['type']}',
      ),
      status: RefundStatus.values.firstWhere(
        (e) => e.toString() == 'RefundStatus.${json['status']}',
      ),
      reason: RefundReason.values.firstWhere(
        (e) => e.toString() == 'RefundReason.${json['reason']}',
      ),
      description: json['description'] as String?,
      originalAmount: (json['originalAmount'] as num).toDouble(),
      refundAmount: (json['refundAmount'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((item) => RefundItem.fromJson(item))
          .toList(),
      processedBy: json['processedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receiptId': receiptId,
      'orderId': orderId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'reason': reason.toString().split('.').last,
      'description': description,
      'originalAmount': originalAmount,
      'refundAmount': refundAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'processedBy': processedBy,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  // Create a copy with updated fields
  Refund copyWith({
    String? id,
    String? receiptId,
    String? orderId,
    RefundType? type,
    RefundStatus? status,
    RefundReason? reason,
    String? description,
    double? originalAmount,
    double? refundAmount,
    List<RefundItem>? items,
    String? processedBy,
    DateTime? createdAt,
    DateTime? processedAt,
    String? notes,
  }) {
    return Refund(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      originalAmount: originalAmount ?? this.originalAmount,
      refundAmount: refundAmount ?? this.refundAmount,
      items: items ?? this.items,
      processedBy: processedBy ?? this.processedBy,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      notes: notes ?? this.notes,
    );
  }

  // Get display name for refund type
  String get typeDisplayName {
    switch (type) {
      case RefundType.full:
        return 'Full Refund';
      case RefundType.partial:
        return 'Partial Refund';
      case RefundType.exchange:
        return 'Exchange';
    }
  }

  // Get display name for refund status
  String get statusDisplayName {
    switch (status) {
      case RefundStatus.pending:
        return 'Pending';
      case RefundStatus.approved:
        return 'Approved';
      case RefundStatus.completed:
        return 'Completed';
      case RefundStatus.rejected:
        return 'Rejected';
    }
  }

  // Get display name for refund reason
  String get reasonDisplayName {
    switch (reason) {
      case RefundReason.customerRequest:
        return 'Customer Request';
      case RefundReason.wrongItem:
        return 'Wrong Item';
      case RefundReason.qualityIssue:
        return 'Quality Issue';
      case RefundReason.duplicateCharge:
        return 'Duplicate Charge';
      case RefundReason.systemError:
        return 'System Error';
      case RefundReason.other:
        return 'Other';
    }
  }

  // Check if refund is pending
  bool get isPending => status == RefundStatus.pending;

  // Check if refund is completed
  bool get isCompleted => status == RefundStatus.completed;

  // Check if refund is rejected
  bool get isRejected => status == RefundStatus.rejected;

  // Get refund percentage
  double get refundPercentage => (refundAmount / originalAmount) * 100;
}

class RefundItem {
  final String itemId;
  final String itemName;
  final double originalPrice;
  final double refundPrice;
  final int originalQuantity;
  final int refundQuantity;
  final String? reason;

  const RefundItem({
    required this.itemId,
    required this.itemName,
    required this.originalPrice,
    required this.refundPrice,
    required this.originalQuantity,
    required this.refundQuantity,
    this.reason,
  });

  // Create from JSON
  factory RefundItem.fromJson(Map<String, dynamic> json) {
    return RefundItem(
      itemId: json['itemId'] as String,
      itemName: json['itemName'] as String,
      originalPrice: (json['originalPrice'] as num).toDouble(),
      refundPrice: (json['refundPrice'] as num).toDouble(),
      originalQuantity: json['originalQuantity'] as int,
      refundQuantity: json['refundQuantity'] as int,
      reason: json['reason'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'originalPrice': originalPrice,
      'refundPrice': refundPrice,
      'originalQuantity': originalQuantity,
      'refundQuantity': refundQuantity,
      'reason': reason,
    };
  }

  // Get total refund amount for this item
  double get totalRefundAmount => refundPrice * refundQuantity;

  // Get refund percentage for this item
  double get refundPercentage => (refundPrice / originalPrice) * 100;
} 