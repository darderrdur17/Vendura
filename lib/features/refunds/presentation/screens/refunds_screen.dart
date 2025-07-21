import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/data/models/refund.dart';
import 'package:vendura/shared/presentation/widgets/animated_card.dart';
import 'package:vendura/shared/presentation/widgets/shimmer_loading.dart';

class RefundsScreen extends ConsumerStatefulWidget {
  const RefundsScreen({super.key});

  @override
  ConsumerState<RefundsScreen> createState() => _RefundsScreenState();
}

class _RefundsScreenState extends ConsumerState<RefundsScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  DateTime? _selectedDate;

  List<String> get filterOptions => ['All', 'Pending', 'Completed', 'Rejected'];

  List<Map<String, dynamic>> get filteredRefunds {
    final refunds = ref.watch(refundsProvider);
    var filtered = refunds.where((refund) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          refund['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          refund['receiptId'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (refund['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      // Status filter
      final matchesStatus = _selectedFilter == 'All' || 
          refund['status'] == _selectedFilter.toLowerCase();
      
      // Date filter
      final matchesDate = _selectedDate == null || 
          _isSameDay(DateTime.parse(refund['createdAt'] as String), _selectedDate!);
      
      return matchesSearch && matchesStatus && matchesDate;
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
        title: const Text('Refunds'),
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
          // Refresh the refunds data
          ref.read(refundsProvider.notifier).state = MockService.getRefunds();
        },
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Search refunds...',
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (_selectedFilter != 'All')
                      Chip(
                        label: Text(_selectedFilter),
                        onDeleted: () => setState(() => _selectedFilter = 'All'),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        deleteIconColor: AppTheme.primaryColor,
                      ),
                    if (_selectedDate != null)
                      Chip(
                        label: Text(_formatDate(_selectedDate!)),
                        onDeleted: () => setState(() => _selectedDate = null),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        deleteIconColor: AppTheme.primaryColor,
                      ),
                  ],
                ),
              ),
            
            // Refunds List
            Expanded(
              child: filteredRefunds.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      itemCount: filteredRefunds.length,
                      itemBuilder: (context, index) {
                        final refund = filteredRefunds[index];
                        return AnimatedCard(
                          onTap: () => _viewRefund(refund),
                          child: _buildRefundCard(refund),
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
              Icons.money_off,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'No refunds found',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Refunds will appear here when processed',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRefundCard(Map<String, dynamic> refund) {
    final refundId = refund['id'] as String;
    final receiptId = refund['receiptId'] as String;
    final type = refund['type'] as String;
    final status = refund['status'] as String;
    final reason = refund['reason'] as String;
    final originalAmount = (refund['originalAmount'] as num).toDouble();
    final refundAmount = (refund['refundAmount'] as num).toDouble();
    final createdAt = DateTime.parse(refund['createdAt'] as String);
    final items = refund['items'] as List<dynamic>? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Refund ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Refund #${refundId.substring(refundId.length - 6)}',
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
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingS),
            
            // Refund Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Receipt #${receiptId.substring(receiptId.length - 6)}',
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
                      const SizedBox(height: 4),
                      Text(
                        _getReasonDisplayName(reason),
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
                      '\$${refundAmount.toStringAsFixed(2)}',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'of \$${originalAmount.toStringAsFixed(2)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    Text(
                      _getTypeDisplayName(type),
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
                    onPressed: () => _viewRefund(refund),
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
                    onPressed: () => _processRefund(refund),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Process'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _printRefund(refund),
                    icon: const Icon(Icons.print, size: 16),
                    label: const Text('Print'),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'approved':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type.toLowerCase()) {
      case 'full':
        return 'Full Refund';
      case 'partial':
        return 'Partial Refund';
      case 'exchange':
        return 'Exchange';
      default:
        return 'Refund';
    }
  }

  String _getReasonDisplayName(String reason) {
    switch (reason.toLowerCase()) {
      case 'customerrequest':
        return 'Customer Request';
      case 'wrongitem':
        return 'Wrong Item';
      case 'qualityissue':
        return 'Quality Issue';
      case 'duplicatecharge':
        return 'Duplicate Charge';
      case 'systemerror':
        return 'System Error';
      case 'other':
        return 'Other';
      default:
        return 'Unknown';
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
        title: const Text('Filter Refunds'),
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

  void _viewRefund(Map<String, dynamic> refund) {
    // TODO: Navigate to refund detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing refund ${refund['id']}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _processRefund(Map<String, dynamic> refund) {
    // TODO: Implement refund processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing refund ${refund['id']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _printRefund(Map<String, dynamic> refund) {
    // TODO: Implement refund printing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing refund ${refund['id']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 