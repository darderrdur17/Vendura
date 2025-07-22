import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/data/models/receipt.dart';
import 'package:vendura/features/receipts/presentation/widgets/receipt_template.dart';

class RefundDetailScreen extends ConsumerStatefulWidget {
  final String refundId;
  const RefundDetailScreen({super.key, required this.refundId});

  @override
  ConsumerState<RefundDetailScreen> createState() => _RefundDetailScreenState();
}

class _RefundDetailScreenState extends ConsumerState<RefundDetailScreen> {
  Map<String, dynamic>? _refund;
  Receipt? _originalReceipt;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final refund = MockService.getRefund(widget.refundId);
    if (refund != null) {
      final receiptData = MockService.getReceipt(refund['receiptId']);
      if (receiptData != null) {
        _originalReceipt = Receipt.fromJson(receiptData);
      }
    }
    setState(() {
      _refund = refund;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Refund ${widget.refundId}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _refund == null
              ? Center(child: Text('Refund not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_originalReceipt != null)
                        ReceiptTemplate(receipt: _originalReceipt!),
                      const SizedBox(height: 16),
                      Text('Refund Reason: ${_refund!['reason']}'),
                      Text('Status: ${_refund!['status']}'),
                      Text('Amount: -\$${(_refund!['refundAmount'] as num).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
    );
  }
} 