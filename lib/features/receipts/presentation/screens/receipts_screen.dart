import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/shared/presentation/widgets/animated_card.dart';
import 'package:vendura/shared/presentation/widgets/shimmer_loading.dart';
import 'package:vendura/data/models/receipt.dart';

class ReceiptsScreen extends ConsumerStatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  ConsumerState<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends ConsumerState<ReceiptsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  DateTime? _selectedDate;

  List<String> get filterOptions => ['All', 'Today', 'This Week', 'This Month'];

  List<Map<String, dynamic>> get filteredReceipts {
    final receipts = ref.watch(receiptsProvider);
    var filtered = receipts.where((receipt) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          receipt['orderId'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          receipt['total'].toString().contains(_searchQuery);
      
      // Date filter
      final matchesDate = _selectedDate == null || 
          _isSameDay(DateTime.parse(receipt['createdAt'] as String), _selectedDate!);
      
      return matchesSearch && matchesDate;
    }).toList();

    // Sort by date (newest first)
    filtered.sort((a, b) => DateTime.parse(b['createdAt'] as String)
        .compareTo(DateTime.parse(a['createdAt'] as String)));

    return filtered;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showDatePicker,
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Filter by Date',
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh the receipts data
          ref.read(receiptsProvider.notifier).state = MockService.getReceipts();
        },
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Search receipts...',
                  prefixIcon: Icons.search,
                  suffixIcon: _searchQuery.isNotEmpty ? Icons.clear : null,
                  onSuffixPressed: _searchQuery.isNotEmpty
                      ? () => setState(() => _searchQuery = '')
                      : null,
                ),
              ),
            ),
            
            // Filter Chips
            if (_selectedFilter != 'All' || _selectedDate != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                child: Wrap(
                  spacing: AppTheme.spacingS,
                  children: [
                    if (_selectedFilter != 'All')
                      Chip(
                        label: Text(_selectedFilter),
                        onDeleted: () => setState(() => _selectedFilter = 'All'),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        deleteIconColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    if (_selectedDate != null)
                      Chip(
                        label: Text(_formatDate(_selectedDate!)),
                        onDeleted: () => setState(() => _selectedDate = null),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        deleteIconColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                  ],
                ),
              ),
            
            // Receipts List
            Expanded(
              child: filteredReceipts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      itemCount: filteredReceipts.length,
                      itemBuilder: (context, index) {
                        final receipt = filteredReceipts[index];
                        return AnimatedCard(
                          onTap: () => _viewReceipt(receipt),
                          child: _buildReceiptCard(receipt),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'No receipts found',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Receipts will appear here after completing orders',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(Map<String, dynamic> receipt) {
    final receiptId = receipt['id'] as String;
    final orderId = receipt['orderId'] as String;
    final total = (receipt['total'] as num).toDouble();
    final paymentMethod = receipt['paymentMethod'] as String;
    final createdAt = DateTime.parse(receipt['createdAt'] as String);
    final items = receipt['items'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Receipt ID and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt #${receiptId.substring(receiptId.length - 6)}',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatDateTime(createdAt),
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentMethodColor(paymentMethod).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(
                    paymentMethod,
                    style: TextStyle(
                      color: _getPaymentMethodColor(paymentMethod),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            // Receipt Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${orderId.substring(orderId.length - 6)}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${items.length} items',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      _getPaymentMethodDescription(paymentMethod),
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewReceipt(receipt),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _printReceipt(receipt),
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Print'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _emailReceipt(receipt),
                    icon: const Icon(Icons.email, size: 16),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  String _getPaymentMethodDescription(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash payment';
      case 'card':
        return 'Card payment';
      case 'mobile':
        return 'Mobile payment';
      case 'split':
        return 'Split payment';
      default:
        return 'Payment completed';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Receipts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: filterOptions.map((filter) {
            return RadioListTile<String>(
              title: Text(filter),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _viewReceipt(Map<String, dynamic> receipt) {
    Navigator.pushNamed(
      context,
      '/receipt-detail',
      arguments: {'receiptId': receipt['id']},
    );
  }

  void _printReceipt(Map<String, dynamic> receipt) {
    // TODO: Implement printing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing receipt ${receipt['id']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _emailReceipt(Map<String, dynamic> receipt) {
    // TODO: Implement email functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Emailing receipt ${receipt['id']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 