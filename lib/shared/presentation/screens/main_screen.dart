import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:vendura/features/orders/presentation/screens/order_screen.dart';
import 'package:vendura/features/receipts/presentation/screens/receipts_screen.dart';
import 'package:vendura/features/refunds/presentation/screens/refunds_screen.dart';
import 'package:vendura/features/reports/presentation/screens/reports_screen.dart';
import 'package:vendura/features/settings/presentation/screens/settings_screen.dart';
import 'package:vendura/core/services/mock_service.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const OrderScreen(), // New Order is now the main page
    const ReceiptsScreen(),
    const OrdersListScreen(),
    const RefundsScreen(),
  ];

  final List<BottomNavigationBarItem> _bottomNavItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.add_shopping_cart),
      label: 'New Order',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long),
      label: 'Receipts',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.list_alt),
      label: 'Orders',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.money_off),
      label: 'Refunds',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          items: _bottomNavItems,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              onPressed: _showOrderOptions,
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, size: 24),
              heroTag: 'main_fab',
            )
          : null,
    );
  }

  // Show bottom sheet with New Order and Ongoing Order options
  void _showOrderOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Order'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/order',
                    arguments: {'isNewOrder': true},
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_play),
                title: const Text('Ongoing Order'),
                onTap: () {
                  Navigator.pop(context);
                  _showOngoingOrdersList();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show list of ongoing orders (pending or in progress)
  void _showOngoingOrdersList() {
    final orders = ref.read(ordersProvider).where((order) {
      final status = (order['status'] as String).toLowerCase();
      return status == 'pending' || status == 'in progress';
    }).toList();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Select Ongoing Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    title: Text(order['id'] as String),
                    subtitle: Text(order['status'] as String),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/order',
                        arguments: {
                          'orderId': order['id'],
                          'isNewOrder': false,
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
} 