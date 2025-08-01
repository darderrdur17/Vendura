import 'package:flutter/material.dart';
import 'package:vendura/features/auth/presentation/screens/login_screen.dart';
import 'package:vendura/features/auth/presentation/screens/splash_screen.dart';
import 'package:vendura/features/orders/presentation/screens/order_screen.dart';
import 'package:vendura/features/orders/presentation/screens/order_details_screen.dart';
import 'package:vendura/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:vendura/features/payments/presentation/screens/payment_screen.dart';
import 'package:vendura/features/receipts/presentation/screens/receipts_screen.dart';
import 'package:vendura/features/receipts/presentation/screens/receipt_detail_screen.dart';
import 'package:vendura/features/refunds/presentation/screens/refunds_screen.dart';
import 'package:vendura/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:vendura/features/reports/presentation/screens/reports_screen.dart';
import 'package:vendura/features/settings/presentation/screens/settings_screen.dart';
import 'package:vendura/features/settings/presentation/screens/cafe_settings_screen.dart';
import 'package:vendura/features/settings/presentation/screens/menu_management_screen.dart';
import 'package:vendura/features/settings/presentation/screens/payment_methods_screen.dart';
import 'package:vendura/features/settings/presentation/screens/receipt_settings_screen.dart';
import 'package:vendura/features/settings/presentation/screens/backup_restore_screen.dart';
import 'package:vendura/features/settings/presentation/screens/sync_settings_screen.dart';
import 'package:vendura/features/settings/presentation/screens/app_details_screen.dart';
import 'package:vendura/features/settings/presentation/screens/help_support_screen.dart';
import 'package:vendura/shared/presentation/screens/main_screen.dart';
import 'package:vendura/features/profile/presentation/screens/profile_screen.dart';
import 'package:vendura/features/refunds/presentation/screens/refund_detail_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String orders = '/orders';
  static const String order = '/order';
  static const String orderDetails = '/order-details';
  static const String payment = '/payment';
  static const String receipts = '/receipts';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String refundDetail = '/refund-detail';

  static String get initialRoute => splash;

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      
      case '/login':
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      
      case '/main':
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MainScreen(
            initialTabIndex: args?['initialTabIndex'],
          ),
        );
      
      case '/orders':
        return MaterialPageRoute(
          builder: (_) => const OrdersListScreen(),
        );
      
      case '/order':
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OrderScreen(
            orderId: args?['orderId'],
            isNewOrder: args?['isNewOrder'] ?? true,
          ),
        );
      
      case '/order-details':
        return MaterialPageRoute(
          builder: (_) => const OrderDetailsScreen(),
        );
      
      case '/payment':
        return MaterialPageRoute(
          builder: (_) => const PaymentScreen(),
        );
      
      case '/receipts':
        return MaterialPageRoute(
          builder: (_) => const ReceiptsScreen(),
        );
      
      case '/receipt-detail':
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ReceiptDetailScreen(
            receiptId: args?['receiptId'] ?? '',
          ),
        );
      
      case '/refunds':
        return MaterialPageRoute(
          builder: (_) => const RefundsScreen(),
        );
      
      case '/inventory':
        return MaterialPageRoute(
          builder: (_) => const InventoryScreen(),
        );
      
      case '/reports':
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
        );
      
      case '/settings':
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      
      case '/cafe-settings':
        return MaterialPageRoute(
          builder: (_) => const CafeSettingsScreen(),
        );
      
      case '/menu-management':
        return MaterialPageRoute(
          builder: (_) => const MenuManagementScreen(),
        );
      
      case '/payment-methods':
        return MaterialPageRoute(
          builder: (_) => const PaymentMethodsScreen(),
        );
      
      case '/receipt-settings':
        return MaterialPageRoute(
          builder: (_) => const ReceiptSettingsScreen(),
        );
      
      case '/backup-restore':
        return MaterialPageRoute(
          builder: (_) => const BackupRestoreScreen(),
        );
      
      case '/sync-settings':
        return MaterialPageRoute(
          builder: (_) => const SyncSettingsScreen(),
        );
      
      case '/app-details':
        return MaterialPageRoute(
          builder: (_) => const AppDetailsScreen(),
        );
      
      case '/help-support':
        return MaterialPageRoute(
          builder: (_) => const HelpSupportScreen(),
        );
      
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case '/refund-detail':
        final args = routeSettings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => RefundDetailScreen(refundId: args?['refundId'] ?? ''));
      
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Route not found'),
            ),
          ),
        );
    }
  }
} 