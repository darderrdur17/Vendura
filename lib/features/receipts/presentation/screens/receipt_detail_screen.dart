import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/data/models/receipt.dart';
import 'package:vendura/features/receipts/presentation/widgets/receipt_template.dart';
import 'package:vendura/core/services/receipt_share_service.dart';

class ReceiptDetailScreen extends ConsumerStatefulWidget {
  final String receiptId;

  const ReceiptDetailScreen({
    super.key,
    required this.receiptId,
  });

  @override
  ConsumerState<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  Receipt? _receipt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    try {
      // Try to get receipt directly from MockService
      final receiptData = MockService.getReceipt(widget.receiptId);
      
      if (receiptData != null) {
        setState(() {
          _receipt = Receipt.fromJson(receiptData);
          _isLoading = false;
        });
      } else {
        // Fallback to provider
        final receipts = ref.read(receiptsProvider);
        final fallbackReceiptData = receipts.firstWhere(
          (receipt) => receipt['id'] == widget.receiptId,
          orElse: () => {},
        );
        
        if (fallbackReceiptData.isNotEmpty) {
          setState(() {
            _receipt = Receipt.fromJson(fallbackReceiptData);
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading receipt: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt #${_getReceiptDisplayId()}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _previewReceipt,
            icon: const Icon(Icons.preview),
            tooltip: 'Preview Receipt',
          ),
          IconButton(
            onPressed: _printReceipt,
            icon: const Icon(Icons.print),
            tooltip: 'Print Receipt',
          ),
          IconButton(
            onPressed: _emailReceipt,
            icon: const Icon(Icons.email),
            tooltip: 'Email Receipt',
          ),
          IconButton(
            onPressed: _shareReceipt,
            icon: const Icon(Icons.share),
            tooltip: 'Share Receipt',
          ),
          IconButton(
            onPressed: _createRefund,
            icon: const Icon(Icons.money_off),
            tooltip: 'Create Refund',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _receipt == null
              ? _buildErrorState()
              : _buildReceiptView(),
    );
  }

  String _getReceiptDisplayId() {
    if (widget.receiptId.isEmpty) return 'N/A';
    if (widget.receiptId.length <= 6) return widget.receiptId;
    return widget.receiptId.substring(widget.receiptId.length - 6);
  }

  Widget _buildErrorState() {
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
            'Receipt not found',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The requested receipt could not be found',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Receipt Template
          ReceiptTemplate(receipt: _receipt!),
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _printReceipt,
                  icon: const Icon(Icons.print),
                  label: const Text('Print'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _emailReceipt,
                  icon: const Icon(Icons.email),
                  label: const Text('Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareReceipt,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Receipt Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipt Details',
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Receipt ID', _receipt!.id),
                  _buildDetailRow('Order ID', _receipt!.orderId),
                  _buildDetailRow('Date', _formatDateTime(_receipt!.createdAt)),
                  _buildDetailRow('Time', _formatTime(_receipt!.createdAt)),
                  _buildDetailRow('Payment Method', _receipt!.paymentMethod.displayName),
                  _buildDetailRow('Items', '${_receipt!.items.length} items'),
                  _buildDetailRow('Subtotal', '\$${_receipt!.subtotal.toStringAsFixed(2)}'),
                  _buildDetailRow('Tip', '\$${_receipt!.tip.toStringAsFixed(2)}'),
                  _buildDetailRow('Total', '\$${_receipt!.total.toStringAsFixed(2)}'),
                  _buildDetailRow('Amount Paid', '\$${_receipt!.amountPaid.toStringAsFixed(2)}'),
                  if (_receipt!.change > 0)
                    _buildDetailRow('Change', '\$${_receipt!.change.toStringAsFixed(2)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _previewReceipt() {
    // TODO: Implement preview functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Previewing receipt ${_receipt!.id}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _printReceipt() async {
    if (_receipt == null) return;
    try {
      await ReceiptShareService.printReceipt(_receipt!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Printing failed: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _emailReceipt() {
    if (_receipt == null) return;
    ReceiptShareService.emailReceipt(_receipt!);
  }

  void _shareReceipt() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing receipt ${_receipt!.id}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _createRefund() {
    // TODO: Navigate to refund creation screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating refund for receipt ${_receipt!.id}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 