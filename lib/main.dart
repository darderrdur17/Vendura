import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/routing/app_router.dart';
import 'package:vendura/core/services/platform_service.dart';
import 'package:vendura/features/orders/presentation/screens/orders_list_screen.dart';
import 'package:vendura/features/orders/presentation/screens/order_screen.dart';
import 'package:vendura/features/orders/presentation/screens/order_details_screen.dart';
import 'package:vendura/features/payments/presentation/screens/payment_screen.dart';
import 'package:vendura/features/receipts/presentation/screens/receipts_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize platform-specific services
  await _initializePlatformServices();
  
  runApp(
    const ProviderScope(
      child: VenduraApp(),
    ),
  );
}

Future<void> _initializePlatformServices() async {
  // Platform-specific initialization
  if (PlatformService.isWeb) {
    // Web-specific initialization
    debugPrint('Initializing Vendura POS for Web platform');
  } else {
    // Mobile-specific initialization
    debugPrint('Initializing Vendura POS for ${PlatformService.platformName} platform');
  }
}

class VenduraApp extends ConsumerWidget {
  const VenduraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Vendura POS',
      debugShowCheckedModeBanner: PlatformService.isDebugMode,
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
      builder: (context, child) {
        // Add platform-specific wrapper
        return _PlatformWrapper(child: child!);
      },
    );
  }
}

class _PlatformWrapper extends StatelessWidget {
  final Widget child;

  const _PlatformWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    if (PlatformService.isWeb) {
      // Web-specific wrapper
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaleFactor: 1.0, // Prevent text scaling on web
        ),
        child: child,
      );
    }
    
    // Mobile wrapper
    return child;
  }
} 