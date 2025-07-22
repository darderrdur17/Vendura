import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/routing/app_router.dart';
import 'package:vendura/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:vendura/features/orders/presentation/screens/order_screen.dart';
import 'package:vendura/features/orders/presentation/screens/order_details_screen.dart';
import 'package:vendura/features/payments/presentation/screens/payment_screen.dart';
import 'package:vendura/features/receipts/presentation/screens/receipts_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: VenduraApp(),
    ),
  );
}

class VenduraApp extends ConsumerWidget {
  const VenduraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Vendura POS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.initialRoute,
      routes: {
        '/orders': (context) => const OrdersListScreen(),
        '/order': (context) => const OrderScreen(),
        '/order-details': (context) => const OrderDetailsScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/receipts': (context) => const ReceiptsScreen(),
      },
    );
  }
} 