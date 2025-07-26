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
  bool _isLoading = false;

  List<String> get filterOptions => ['All', 'Today', 'This Week', 'This Month', 'High Value', 'Recent'];

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
      
      // Status filter
      final matchesFilter = _selectedFilter == 'All' || _matchesFilter(receipt);
      
      return matchesSearch && matchesDate && matchesFilter;
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

  bool _matchesFilter(Map<String, dynamic> receipt) {
    final total = receipt['total'] as num;
    final createdAt = DateTime.parse(receipt['createdAt'] as String);
    final now = DateTime.now();

    switch (_selectedFilter) {
      case 'Today':
        return _isSameDay(createdAt, now);
      case 'This Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return createdAt.isAfter(weekAgo);
      case 'This Month':
        return createdAt.month == now.month && createdAt.year == now.year;
      case 'High Value':
        return total > 50.0;
      case 'Recent':
        final dayAgo = now.subtract(const Duration(days: 1));
        return createdAt.isAfter(dayAgo);
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
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
          IconButton(
            onPressed: _exportReceipts,
            icon: const Icon(Icons.download),
            tooltip: 'Export',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoading = true);
          await Future.delayed(const Duration(seconds: 1));
          ref.read(receiptsProvider.notifier).state = MockService.getReceipts();
          setState(() => _isLoading = false);
        },
        child: Column(
          children: [
            // Header Stats
            _buildHeaderStats(),
            
            // Search and Filter Bar
            _buildSearchAndFilter(),
            
            // Receipts List
            Expanded(
              child: _isLoading
                  ? const ShimmerLoading()
                  : filteredReceipts.isEmpty
                      ? _buildEmptyState()
                      : _buildReceiptsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStats() {
    final receipts = ref.watch(receiptsProvider);
    final todayReceipts = receipts.where((receipt) {
      final createdAt = DateTime.parse(receipt['createdAt'] as String);
      return _isSameDay(createdAt, DateTime.now());
    }).toList();
    
    final totalToday = todayReceipts.fold<double>(0.0, (sum, receipt) => sum + (receipt['total'] as num));
    final totalAll = receipts.fold<double>(0.0, (sum, receipt) => sum + (receipt['total'] as num));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Today\'s Sales',
              '\$${totalToday.toStringAsFixed(2)}',
              '${todayReceipts.length} receipts',
              Icons.today,
              AppTheme.successGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Sales',
              '\$${totalAll.toStringAsFixed(2)}',
              '${receipts.length} receipts',
              Icons.receipt_long,
              AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.trending_up, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search receipts...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() => _searchQuery = ''),
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          
          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filterOptions.length,
              itemBuilder: (context, index) {
                final filter = filterOptions[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    elevation: isSelected ? 2 : 0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredReceipts.length,
      itemBuilder: (context, index) {
        final receipt = filteredReceipts[index];
        return AnimatedCard(
          child: _buildReceiptCard(receipt),
        );
      },
    );
  }

  Widget _buildReceiptCard(Map<String, dynamic> receipt) {
    final total = receipt['total'] as num;
    final createdAt = DateTime.parse(receipt['createdAt'] as String);
    final orderId = receipt['orderId'] as String;
    final paymentMethod = receipt['paymentMethod'] as String;
    final items = receipt['items'] as List<dynamic>;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewReceipt(receipt),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.receipt,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${orderId.substring(orderId.length - 6)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatDateTime(createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
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
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPaymentMethodColor(paymentMethod).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          paymentMethod,
                          style: TextStyle(
                            fontSize: 10,
                            color: _getPaymentMethodColor(paymentMethod),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Items Preview
              if (items.isNotEmpty) ...[
                Text(
                  '${items.length} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                ...items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '• ${item['name']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        'x${item['quantity']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )),
                if (items.length > 2)
                  Text(
                    '+${items.length - 2} more items',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _printReceipt(receipt),
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareReceipt(receipt),
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _createRefund(receipt),
                      icon: const Icon(Icons.money_off, size: 16),
                      label: const Text('Refund'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No receipts found',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewReceipt,
            icon: const Icon(Icons.add),
            label: const Text('Create First Receipt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return Colors.blue;
      case 'cash':
        return Colors.green;
      case 'paynow':
      case 'paylah':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final receiptDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (receiptDate == today) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (receiptDate == yesterday) {
      return 'Yesterday at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  void _viewReceipt(Map<String, dynamic> receipt) {
    Navigator.pushNamed(
      context,
      '/receipt-detail',
      arguments: {'receiptId': receipt['id']},
    );
  }

  void _printReceipt(Map<String, dynamic> receipt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Printing receipt ${receipt['id']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _shareReceipt(Map<String, dynamic> receipt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing receipt ${receipt['id']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _createRefund(Map<String, dynamic> receipt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating refund for receipt ${receipt['id']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _createNewReceipt() {
    Navigator.pushNamed(context, '/order');
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() => _selectedDate = date);
      }
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Receipts'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: filterOptions.map((filter) => ListTile(
            title: Text(filter),
            trailing: _selectedFilter == filter ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() => _selectedFilter = filter);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _exportReceipts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting receipts...'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 