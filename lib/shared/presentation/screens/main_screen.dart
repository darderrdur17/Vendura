import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:vendura/features/orders/presentation/screens/order_screen.dart';
import 'package:vendura/features/receipts/presentation/screens/receipts_screen.dart';
import 'package:vendura/features/refunds/presentation/screens/refunds_screen.dart';
import 'package:vendura/shared/presentation/widgets/action_menu_overlay.dart';
import 'package:vendura/core/providers/orders_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;
  bool _showActionMenu = false;

  // Pages for bottom-nav
  final List<Widget> _screens = const [
    OrderScreen(), // New Order
    ReceiptsScreen(),
    OrdersListScreen(),
    RefundsScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'New Order'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Receipts'),
    BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.money_off), label: 'Refunds'),
  ];

  // ---------- helpers ----------
  void _openActionMenu() => setState(() => _showActionMenu = true);
  void _closeActionMenu() => setState(() => _showActionMenu = false);

  // List ongoing orders; depending on flags update or delete
  void _showOngoingOrdersList({bool forUpdate = false, bool forDelete = false}) {
    final orders = ref.read(ongoingOrdersProvider);
    final action = forDelete ? 'Delete' : (forUpdate ? 'Update' : 'View');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
                offset: const Offset(0, -5),
            ),
          ],
        ),
          child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
            children: [
                      Icon(
                        forDelete ? Icons.delete_outline : 
                        (forUpdate ? Icons.edit_outlined : Icons.receipt_long),
                        color: forDelete ? Colors.red : 
                        (forUpdate ? Colors.blue : AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$action Ticket',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
                ),
                const Divider(height: 1),
                if (orders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
          child: Column(
            children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No ongoing orders',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6,
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                        final items = (order['items'] as List).cast<Map>();
                        final isSample = order['id'].toString().startsWith('SAMPLE-');
                        
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[200]!,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                if (forDelete) {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: Text('Are you sure you want to delete ${isSample ? "sample " : ""}ticket ${order['id']}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    Navigator.pop(context); // Close bottom sheet
                                    if (!isSample) {
                                      await ref.read(ordersProvider.notifier).deleteOrder(order['id']);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Ticket ${order['id']} has been deleted'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Sample tickets cannot be deleted'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                } else if (forUpdate) {
                                  Navigator.pop(context); // Close bottom sheet
                                  setState(() => _currentIndex = 0); // Switch to Orders tab
                                                        Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/order',
                                    (route) => false,
                        arguments: {
                          'orderId': order['id'],
                          'isNewOrder': false,
                        },
                      );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: order['status'] == 'pending'
                                                ? Colors.orange[100]
                                                : Colors.blue[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            order['status'].toString().toUpperCase(),
                                            style: TextStyle(
                                              color: order['status'] == 'pending'
                                                  ? Colors.orange[900]
                                                  : Colors.blue[900],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: order['orderType'] == 'Takeaway'
                                                ? Colors.purple[100]
                                                : Colors.green[100],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            order['orderType'].toString(),
                                            style: TextStyle(
                                              color: order['orderType'] == 'Takeaway'
                                                  ? Colors.purple[900]
                                                  : Colors.green[900],
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        if (isSample) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'SAMPLE',
                                              style: TextStyle(
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const Spacer(),
                                        Text(
                                          '\$${(order['totalAmount'] as num).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ...items.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '${item['quantity']}× ${item['name']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    )),
                                    if (order['tableNumber'] != null ||
                                        order['customerName'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          order['tableNumber'] != null
                                              ? 'Table ${order['tableNumber']}'
                                              : 'For ${order['customerName']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: _bottomNavItems,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index == 0 && _currentIndex == 0) {
            _openActionMenu();
          } else {
            setState(() => _currentIndex = index);
          }
        },
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              heroTag: 'main_fab',
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              onPressed: _openActionMenu,
              child: const Icon(Icons.more_horiz),
            )
          : null,
    );

    return Stack(
      children: [
        scaffold,
        if (_showActionMenu)
          ActionMenuOverlay(
            onNewTicket: () {
              _closeActionMenu();
              Navigator.pushNamed(context, '/order', arguments: {'isNewOrder': true});
            },
            onUpdateTicket: () {
              _closeActionMenu();
              _showOngoingOrdersList(forUpdate: true);
            },
            onDeleteTicket: () {
              _closeActionMenu();
              _showOngoingOrdersList(forDelete: true);
            },
            onClose: _closeActionMenu,
          ),
      ],
    );
  }
} 