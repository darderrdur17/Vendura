import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedPeriod = 'Today';
  String _selectedReport = 'Sales Summary';

  final List<String> _periods = ['Today', 'This Week', 'This Month', 'This Year'];
  final List<String> _reportTypes = ['Sales Summary', 'Top Items', 'Payment Methods', 'Hourly Sales'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download),
            tooltip: 'Export Report',
          ),
          IconButton(
            onPressed: _shareReport,
            icon: const Icon(Icons.share),
            tooltip: 'Share Report',
          ),
        ],
      ),
      body: Column(
        children: [
          // Period and Report Type Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Period Selector
                Row(
                  children: [
                    const Text('Period: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPeriod,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _periods.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Report Type Selector
                Row(
                  children: [
                    const Text('Report: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedReport,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _reportTypes.map((report) {
                          return DropdownMenuItem(
                            value: report,
                            child: Text(report),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedReport = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Report Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSalesSummary(),
                  const SizedBox(height: 24),
                  _buildTopItems(),
                  const SizedBox(height: 24),
                  _buildPaymentMethodsChart(),
                  const SizedBox(height: 24),
                  _buildHourlySalesChart(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummary() {
    final receipts = ref.watch(receiptsProvider);
    final totalSales = receipts.fold(0.0, (sum, receipt) => sum + (receipt['total'] as num));
    final totalOrders = receipts.length;
    final averageOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Sales Summary',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Sales',
                    '\$${totalSales.toStringAsFixed(2)}',
                    Icons.attach_money,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Total Orders',
                    totalOrders.toString(),
                    Icons.shopping_cart,
                    AppTheme.infoBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    'Avg Order',
                    '\$${averageOrderValue.toStringAsFixed(2)}',
                    Icons.trending_up,
                    AppTheme.successGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopItems() {
    final receipts = ref.watch(receiptsProvider);
    final itemSales = <String, double>{};
    
    // Calculate item sales
    for (final receipt in receipts) {
      final items = receipt['items'] as List<dynamic>? ?? [];
      for (final item in items) {
        final itemName = item['name'] as String;
        final quantity = item['quantity'] as int;
        final price = (item['price'] as num).toDouble();
        final total = quantity * price;
        
        itemSales[itemName] = (itemSales[itemName] ?? 0.0) + total;
      }
    }
    
    // Sort by sales
    final sortedItems = itemSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topItems = sortedItems.take(5).toList();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Top Selling Items',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (topItems.isEmpty)
              const Center(
                child: Text(
                  'No sales data available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: topItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getRankColor(index),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.key,
                            style: AppTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '\$${item.value.toStringAsFixed(2)}',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsChart() {
    final receipts = ref.watch(receiptsProvider);
    final paymentMethods = <String, double>{};
    
    // Calculate payment method totals
    for (final receipt in receipts) {
      final method = receipt['paymentMethod'] as String;
      final total = (receipt['total'] as num).toDouble();
      paymentMethods[method] = (paymentMethods[method] ?? 0.0) + total;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Payment Methods',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (paymentMethods.isEmpty)
              const Center(
                child: Text(
                  'No payment data available',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: paymentMethods.entries.map((entry) {
                  final method = entry.key;
                  final total = entry.value;
                  final percentage = paymentMethods.values.fold(0.0, (sum, value) => sum + value);
                  final percent = percentage > 0 ? (total / percentage) * 100 : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                method,
                                style: AppTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percent / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPaymentMethodColor(method),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${percent.toStringAsFixed(1)}%',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlySalesChart() {
    final receipts = ref.watch(receiptsProvider);
    final hourlySales = List<double>.filled(24, 0.0);
    
    // Calculate hourly sales
    for (final receipt in receipts) {
      final createdAt = DateTime.parse(receipt['createdAt'] as String);
      final hour = createdAt.hour;
      final total = (receipt['total'] as num).toDouble();
      hourlySales[hour] += total;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Hourly Sales',
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: hourlySales.asMap().entries.map((entry) {
                  final hour = entry.key;
                  final sales = entry.value;
                  final maxSales = hourlySales.reduce((a, b) => a > b ? a : b);
                  final height = maxSales > 0 ? (sales / maxSales) * 150 : 0.0;
                  
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 8,
                          height: height,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${hour.toString().padLeft(2, '0')}',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return Colors.amber;
      case 1:
        return Colors.grey[400]!;
      case 2:
        return Colors.brown;
      default:
        return Colors.grey[300]!;
    }
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

  void _exportReport() {
    // TODO: Implement report export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting $_selectedReport for $_selectedPeriod'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _shareReport() {
    // TODO: Implement report sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing $_selectedReport for $_selectedPeriod'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 