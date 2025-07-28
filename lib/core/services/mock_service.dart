import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:vendura/data/models/item.dart';
import 'package:vendura/data/models/order.dart';
import 'package:vendura/data/models/receipt.dart';

class MockService {
  static final Logger _logger = Logger();

  // Mock user data
  static Map<String, dynamic>? _currentUser = {
    'uid': 'mock-user-123',
    'email': 'demo@vendura.com',
    'displayName': 'Demo User',
  };

  // Mock data storage
  static final List<Map<String, dynamic>> _mockItems = [
    // Coffee & Espresso
    {
      'id': 'item-1',
      'name': 'Espresso',
      'category': 'Coffee',
      'price': 3.50,
      'description': 'Single shot of espresso',
      'isAvailable': true,
      'stockQuantity': 50,
      'minStockLevel': 10,
      'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=200',
      'createdAt': DateTime.now().toIso8601String(),
      'addOns': [
        {
          'id': 'addon-1',
          'name': 'Extra Shot',
          'price': 1.00,
          'category': 'Coffee Add-ons',
          'isAvailable': true,
        },
        {
          'id': 'addon-2',
          'name': 'Syrup (Vanilla)',
          'price': 0.50,
          'category': 'Syrups',
          'isAvailable': true,
        },
        {
          'id': 'addon-3',
          'name': 'Syrup (Caramel)',
          'price': 0.50,
          'category': 'Syrups',
          'isAvailable': true,
        },
      ],
    },
    {
      'id': 'item-2',
      'name': 'Double Espresso',
      'category': 'Coffee',
      'price': 4.50,
      'description': 'Double shot of espresso',
      'isAvailable': true,
      'stockQuantity': 45,
      'minStockLevel': 10,
      'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=200',
      'createdAt': DateTime.now().toIso8601String(),
      'addOns': [
        {
          'id': 'addon-1',
          'name': 'Extra Shot',
          'price': 1.00,
          'category': 'Coffee Add-ons',
          'isAvailable': true,
        },
        {
          'id': 'addon-2',
          'name': 'Syrup (Vanilla)',
          'price': 0.50,
          'category': 'Syrups',
          'isAvailable': true,
        },
        {
          'id': 'addon-3',
          'name': 'Syrup (Caramel)',
          'price': 0.50,
          'category': 'Syrups',
          'isAvailable': true,
        },
      ],
    },
    {
      'id': 'item-3',
      'name': 'Cappuccino',
      'category': 'Coffee',
      'price': 4.50,
      'description': 'Espresso with steamed milk and foam',
      'isAvailable': true,
      'stockQuantity': 60,
      'minStockLevel': 15,
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
      'addOns': [
        {
          'id': 'addon-1',
          'name': 'Extra Shot',
          'price': 1.00,
          'category': 'Coffee Add-ons',
          'isAvailable': true,
        },
        {
          'id': 'addon-2',
          'name': 'Syrup (Vanilla)',
          'price': 0.50,
          'category': 'Syrups',
          'isAvailable': true,
        },
        {
          'id': 'addon-3',
          'name': 'Syrup (Caramel)',
          'price': 0.50,
          'category': 'Syrups',
          'isAvailable': true,
        },
        {
          'id': 'addon-4',
          'name': 'Syrup (Hazelnut)',
          'price': 0.50,
          'category': 'Syrups',
          'isAvailable': true,
        },
        {
          'id': 'addon-5',
          'name': 'Extra Foam',
          'price': 0.25,
          'category': 'Milk Add-ons',
          'isAvailable': true,
        },
        {
          'id': 'addon-6',
          'name': 'Almond Milk',
          'price': 0.75,
          'category': 'Milk Substitutes',
          'isAvailable': true,
        },
        {
          'id': 'addon-7',
          'name': 'Oat Milk',
          'price': 0.75,
          'category': 'Milk Substitutes',
          'isAvailable': true,
        },
      ],
    },
    {
      'id': 'item-4',
      'name': 'Latte',
      'category': 'Coffee',
      'price': 4.75,
      'description': 'Espresso with steamed milk',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-5',
      'name': 'Americano',
      'category': 'Coffee',
      'price': 3.75,
      'description': 'Espresso with hot water',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-6',
      'name': 'Mocha',
      'category': 'Coffee',
      'price': 5.25,
      'description': 'Espresso with chocolate and steamed milk',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-7',
      'name': 'Flat White',
      'category': 'Coffee',
      'price': 4.75,
      'description': 'Espresso with microfoam',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    
    // Specialty Coffee
    {
      'id': 'item-8',
      'name': 'Pour Over',
      'category': 'Specialty Coffee',
      'price': 4.00,
      'description': 'Hand-crafted pour over coffee',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-9',
      'name': 'Cold Brew',
      'category': 'Specialty Coffee',
      'price': 4.50,
      'description': '12-hour cold brewed coffee',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-10',
      'name': 'Nitro Cold Brew',
      'category': 'Specialty Coffee',
      'price': 5.50,
      'description': 'Nitrogen-infused cold brew',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-11',
      'name': 'Chemex',
      'category': 'Specialty Coffee',
      'price': 5.00,
      'description': 'Chemex-brewed single origin coffee',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    
    // Tea
    {
      'id': 'item-12',
      'name': 'Earl Grey',
      'category': 'Tea',
      'price': 3.50,
      'description': 'Classic Earl Grey tea',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-13',
      'name': 'Chai Latte',
      'category': 'Tea',
      'price': 4.75,
      'description': 'Spiced chai with steamed milk',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-14',
      'name': 'Matcha Latte',
      'category': 'Tea',
      'price': 5.25,
      'description': 'Premium matcha with steamed milk',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-15',
      'name': 'Green Tea',
      'category': 'Tea',
      'price': 3.25,
      'description': 'Organic green tea',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    
    // Pastries & Baked Goods
    {
      'id': 'item-16',
      'name': 'Croissant',
      'category': 'Pastry',
      'price': 3.50,
      'description': 'Buttery French croissant',
      'isAvailable': true,
      'stockQuantity': 25,
      'minStockLevel': 5,
      'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200',
      'createdAt': DateTime.now().toIso8601String(),
      'addOns': [
        {
          'id': 'addon-8',
          'name': 'Butter',
          'price': 0.25,
          'category': 'Food Add-ons',
          'isAvailable': true,
        },
        {
          'id': 'addon-9',
          'name': 'Jam (Strawberry)',
          'price': 0.50,
          'category': 'Food Add-ons',
          'isAvailable': true,
        },
        {
          'id': 'addon-10',
          'name': 'Jam (Apricot)',
          'price': 0.50,
          'category': 'Food Add-ons',
          'isAvailable': true,
        },
        {
          'id': 'addon-11',
          'name': 'Honey',
          'price': 0.50,
          'category': 'Food Add-ons',
          'isAvailable': true,
        },
      ],
    },
    {
      'id': 'item-17',
      'name': 'Chocolate Croissant',
      'category': 'Pastry',
      'price': 4.00,
      'description': 'Croissant filled with dark chocolate',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-18',
      'name': 'Blueberry Muffin',
      'category': 'Pastry',
      'price': 3.75,
      'description': 'Fresh blueberry muffin',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-19',
      'name': 'Cinnamon Roll',
      'category': 'Pastry',
      'price': 4.25,
      'description': 'Warm cinnamon roll with glaze',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-20',
      'name': 'Scone',
      'category': 'Pastry',
      'price': 3.50,
      'description': 'Traditional English scone',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    
    // Unique Specialties
    {
      'id': 'item-21',
      'name': 'Lavender Honey Latte',
      'category': 'Specialties',
      'price': 6.50,
      'description': 'Espresso with lavender-infused honey and steamed milk',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-22',
      'name': 'Maple Bacon Latte',
      'category': 'Specialties',
      'price': 7.00,
      'description': 'Espresso with maple syrup and bacon bits',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-23',
      'name': 'Rose Cardamom Cappuccino',
      'category': 'Specialties',
      'price': 6.75,
      'description': 'Cappuccino with rose water and cardamom',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-24',
      'name': 'Salted Caramel Mocha',
      'category': 'Specialties',
      'price': 6.25,
      'description': 'Mocha with salted caramel sauce',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-25',
      'name': 'Orange Blossom Cold Brew',
      'category': 'Specialties',
      'price': 6.00,
      'description': 'Cold brew with orange blossom water',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    
    // Food Items
    {
      'id': 'item-26',
      'name': 'Avocado Toast',
      'category': 'Food',
      'price': 8.50,
      'description': 'Sourdough toast with avocado, sea salt, and red pepper flakes',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-27',
      'name': 'Breakfast Sandwich',
      'category': 'Food',
      'price': 9.00,
      'description': 'Egg, cheese, and bacon on English muffin',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-28',
      'name': 'Quiche Lorraine',
      'category': 'Food',
      'price': 7.50,
      'description': 'Classic quiche with bacon and cheese',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-29',
      'name': 'Greek Yogurt Parfait',
      'category': 'Food',
      'price': 6.50,
      'description': 'Greek yogurt with granola and fresh berries',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    
    // Beverages
    {
      'id': 'item-30',
      'name': 'Fresh Orange Juice',
      'category': 'Beverages',
      'price': 4.00,
      'description': 'Freshly squeezed orange juice',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-31',
      'name': 'Smoothie Bowl',
      'category': 'Beverages',
      'price': 8.00,
      'description': 'Acai smoothie bowl with fresh fruit and granola',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': 'item-32',
      'name': 'Hot Chocolate',
      'category': 'Beverages',
      'price': 4.50,
      'description': 'Rich hot chocolate with whipped cream',
      'isAvailable': true,
      'imageUrl': 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=200',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> _mockOrders = [
    // Start with an empty list. Only new orders created in the app will appear.
  ];
  static final List<Map<String, dynamic>> _mockReceipts = [
    // Generate some sample receipts
    {
      'id': 'RCP-20241215-0001',
      'orderId': 'ORD-20241215-0001',
      'items': [
        {
          'id': 'item-1',
          'name': 'Espresso',
          'price': 7.00,
          'quantity': 2,
          'imageUrl': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=200',
          'addOns': [
            {
              'id': 'addon-1',
              'name': 'Extra Shot',
              'price': 1.00,
            },
          ],
        },
        {
          'id': 'item-16',
          'name': 'Croissant',
          'price': 3.50,
          'quantity': 1,
          'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200',
        },
      ],
      'subtotal': 10.50,
      'tip': 2.00,
      'total': 12.50,
      'paymentMethod': 'cash',
      'amountPaid': 15.00,
      'change': 2.50,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 'RCP-20241215-0002',
      'orderId': 'ORD-20241215-0002',
      'items': [
        {
          'id': 'item-3',
          'name': 'Cappuccino',
          'price': 4.50,
          'quantity': 1,
          'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
          'addOns': [
            {
              'id': 'addon-6',
              'name': 'Almond Milk',
              'price': 0.75,
            },
          ],
        },
        {
          'id': 'item-21',
          'name': 'Lavender Honey Latte',
          'price': 6.50,
          'quantity': 1,
          'imageUrl': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=200',
        },
        {
          'id': 'item-18',
          'name': 'Blueberry Muffin',
          'price': 7.50,
          'quantity': 2,
          'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=200',
        },
      ],
      'subtotal': 18.25,
      'tip': 3.65,
      'total': 21.90,
      'paymentMethod': 'card',
      'amountPaid': 21.90,
      'change': 0.0,
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
    },
    {
      'id': 'RCP-20241215-0003',
      'orderId': 'ORD-20241215-0003',
      'items': [
        {
          'id': 'item-8',
          'name': 'Pour Over',
          'price': 4.00,
          'quantity': 1,
          'imageUrl': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200',
          'comment': 'Extra hot please',
        },
        {
          'id': 'item-26',
          'name': 'Avocado Toast',
          'price': 8.50,
          'quantity': 1,
          'imageUrl': 'https://images.unsplash.com/photo-1541519227354-08fa5d50c44d?w=200',
          'addOns': [
            {
              'id': 'addon-8',
              'name': 'Extra Avocado',
              'price': 1.50,
            },
          ],
        },
      ],
      'subtotal': 12.50,
      'tip': 2.50,
      'total': 15.00,
      'paymentMethod': 'mobile',
      'amountPaid': 15.00,
      'change': 0.0,
      'createdAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
    },
  ];

  // Mock refunds data
  static final List<Map<String, dynamic>> _mockRefunds = [
    {
      'id': 'refund-1',
      'receiptId': 'RCP-20241215-0001',
      'orderId': 'order-1',
      'type': 'partial',
      'status': 'completed',
      'reason': 'qualityIssue',
      'description': 'Customer reported cold coffee',
      'originalAmount': 12.50,
      'refundAmount': 3.50,
      'items': [
        {
          'itemId': 'item-1',
          'itemName': 'Espresso',
          'originalPrice': 3.50,
          'refundPrice': 3.50,
          'originalQuantity': 1,
          'refundQuantity': 1,
          'reason': 'Cold coffee',
        },
      ],
      'processedBy': 'demo@vendura.com',
      'createdAt': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      'processedAt': DateTime.now().subtract(const Duration(minutes: 30)).toIso8601String(),
      'notes': 'Refunded one espresso due to temperature issue',
    },
    {
      'id': 'refund-2',
      'receiptId': 'RCP-20241215-0002',
      'orderId': 'order-2',
      'type': 'full',
      'status': 'pending',
      'reason': 'customerRequest',
      'description': 'Customer changed mind',
      'originalAmount': 21.90,
      'refundAmount': 21.90,
      'items': [
        {
          'itemId': 'item-21',
          'itemName': 'Lavender Honey Latte',
          'originalPrice': 6.50,
          'refundPrice': 6.50,
          'originalQuantity': 1,
          'refundQuantity': 1,
          'reason': 'Customer request',
        },
        {
          'itemId': 'item-18',
          'itemName': 'Blueberry Muffin',
          'originalPrice': 3.75,
          'refundPrice': 3.75,
          'originalQuantity': 2,
          'refundQuantity': 2,
          'reason': 'Customer request',
        },
      ],
      'processedBy': 'demo@vendura.com',
      'createdAt': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      'notes': 'Customer requested full refund',
    },
  ];

  // Mock settings storage
  static Map<String, dynamic> _mockAppSettings = {};

  static Future<void> setAppSettings(Map<String, dynamic> settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mockAppSettings = Map<String, dynamic>.from(settings);
  }

  static Map<String, dynamic> getAppSettings() {
    return Map<String, dynamic>.from(_mockAppSettings);
  }

  // Authentication
  static Map<String, dynamic>? get currentUser => _currentUser;

  static Future<void> updateCurrentUser({String? displayName, String? email}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser == null) return;
    if (displayName != null && displayName.isNotEmpty) {
      _currentUser!['displayName'] = displayName;
    }
    if (email != null && email.isNotEmpty) {
      _currentUser!['email'] = email;
    }
  }

  static Future<Map<String, dynamic>?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (email == 'demo@vendura.com' && password == 'password') {
      _currentUser = {
        'uid': 'mock-user-123',
        'email': email,
        'displayName': 'Demo User',
      };
      return _currentUser;
    }
    throw Exception('Invalid credentials');
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
  }

  // Items
  static Future<void> addItem(Map<String, dynamic> itemData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    itemData['id'] = 'item-${_mockItems.length + 1}';
    itemData['createdAt'] = DateTime.now().toIso8601String();
    _mockItems.add(itemData);
  }

  static Future<void> updateItem(String itemId, Map<String, dynamic> itemData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockItems.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      _mockItems[index].addAll(itemData);
    }
  }

  static Future<void> deleteItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockItems.removeWhere((item) => item['id'] == itemId);
  }

  static List<Map<String, dynamic>> getItems() {
    return List.from(_mockItems);
  }

  // Stock Management
  static Future<void> updateItemStock(String itemId, int newQuantity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockItems.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      _mockItems[index]['stockQuantity'] = newQuantity;
      // Update availability based on stock
      _mockItems[index]['isAvailable'] = newQuantity > 0;
    }
  }

  static Future<void> setItemAvailability(String itemId, bool isAvailable) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockItems.indexWhere((item) => item['id'] == itemId);
    if (index != -1) {
      _mockItems[index]['isAvailable'] = isAvailable;
    }
  }

  static List<Map<String, dynamic>> getLowStockItems() {
    return _mockItems.where((item) {
      final stockQuantity = item['stockQuantity'] as int? ?? 0;
      final minStockLevel = item['minStockLevel'] as int? ?? 0;
      return stockQuantity <= minStockLevel && stockQuantity > 0;
    }).toList();
  }

  static List<Map<String, dynamic>> getOutOfStockItems() {
    return _mockItems.where((item) {
      final stockQuantity = item['stockQuantity'] as int? ?? 0;
      return stockQuantity <= 0;
    }).toList();
  }

  // Add-ons Management
  static List<Map<String, dynamic>> getAddOnsForItem(String itemId) {
    final item = _mockItems.firstWhere((item) => item['id'] == itemId);
    return item['addOns'] as List<Map<String, dynamic>>? ?? [];
  }

  static Future<void> updateAddOn(String itemId, String addOnId, Map<String, dynamic> addOnData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final itemIndex = _mockItems.indexWhere((item) => item['id'] == itemId);
    if (itemIndex != -1) {
      final addOns = _mockItems[itemIndex]['addOns'] as List<Map<String, dynamic>>? ?? [];
      final addOnIndex = addOns.indexWhere((addon) => addon['id'] == addOnId);
      if (addOnIndex != -1) {
        addOns[addOnIndex].addAll(addOnData);
        _mockItems[itemIndex]['addOns'] = addOns;
      }
    }
  }

  static Future<void> addAddOnToItem(String itemId, Map<String, dynamic> addOnData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final itemIndex = _mockItems.indexWhere((item) => item['id'] == itemId);
    if (itemIndex != -1) {
      final addOns = _mockItems[itemIndex]['addOns'] as List<Map<String, dynamic>>? ?? [];
      addOns.add(addOnData);
      _mockItems[itemIndex]['addOns'] = addOns;
    }
  }

  static Future<void> removeAddOnFromItem(String itemId, String addOnId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final itemIndex = _mockItems.indexWhere((item) => item['id'] == itemId);
    if (itemIndex != -1) {
      final addOns = _mockItems[itemIndex]['addOns'] as List<Map<String, dynamic>>? ?? [];
      addOns.removeWhere((addon) => addon['id'] == addOnId);
      _mockItems[itemIndex]['addOns'] = addOns;
    }
  }

  // Orders
  static Future<String> addOrder(Map<String, dynamic> orderData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour}${now.minute}${now.second}'.padLeft(6, '0');
    final orderNumber = (_mockOrders.length + 1).toString().padLeft(3, '0');
    final orderId = 'ORD-$dateStr-$timeStr-$orderNumber';
    
    orderData['id'] = orderId;
    orderData['createdAt'] = now.toIso8601String();
    _mockOrders.add(orderData);
    return orderId;
  }

  static Future<void> updateOrder(String orderId, Map<String, dynamic> orderData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockOrders.indexWhere((order) => order['id'] == orderId);
    if (index != -1) {
      _mockOrders[index].addAll(orderData);
    }
  }

  static Future<void> deleteOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockOrders.removeWhere((order) => order['id'] == orderId);
  }

  static List<Map<String, dynamic>> getOrders() {
    return List.from(_mockOrders);
  }

  static Map<String, dynamic>? getOrder(String orderId) {
    try {
      return _mockOrders.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }

  // Receipts
  static Future<String> addReceipt(Map<String, dynamic> receiptData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour}${now.minute}${now.second}'.padLeft(6, '0');
    final receiptNumber = (_mockReceipts.length + 1).toString().padLeft(3, '0');
    final receiptId = 'RCP-$dateStr-$timeStr-$receiptNumber';
    
    receiptData['id'] = receiptId;
    receiptData['createdAt'] = now.toIso8601String();
    _mockReceipts.add(receiptData);
    return receiptId;
  }

  static Future<void> updateReceipt(String receiptId, Map<String, dynamic> receiptData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockReceipts.indexWhere((receipt) => receipt['id'] == receiptId);
    if (index != -1) {
      _mockReceipts[index].addAll(receiptData);
    }
  }

  static List<Map<String, dynamic>> getReceipts() {
    return List.from(_mockReceipts);
  }

  static Map<String, dynamic>? getReceipt(String receiptId) {
    try {
      return _mockReceipts.firstWhere((receipt) => receipt['id'] == receiptId);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getReceiptsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _mockReceipts.where((receipt) {
      final createdAt = DateTime.parse(receipt['createdAt']);
      return createdAt.isAfter(startDate) && createdAt.isBefore(endDate);
    }).toList();
  }

  // Refunds
  static Future<String> addRefund(Map<String, dynamic> refundData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final refundId = 'refund-${_mockRefunds.length + 1}';
    refundData['id'] = refundId;
    refundData['createdAt'] = DateTime.now().toIso8601String();
    _mockRefunds.add(refundData);
    return refundId;
  }

  static Future<void> updateRefund(String refundId, Map<String, dynamic> refundData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockRefunds.indexWhere((refund) => refund['id'] == refundId);
    if (index != -1) {
      _mockRefunds[index].addAll(refundData);
    }
  }

  static List<Map<String, dynamic>> getRefunds() {
    return List.from(_mockRefunds);
  }

  static Map<String, dynamic>? getRefund(String refundId) {
    try {
      return _mockRefunds.firstWhere((refund) => refund['id'] == refundId);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> getRefundsByReceipt(String receiptId) {
    return _mockRefunds.where((refund) => refund['receiptId'] == receiptId).toList();
  }

  // Storage (mock)
  static Future<String> uploadFile(String path, List<int> bytes) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'mock-file-url-$path';
  }

  static Future<void> deleteFile(String url) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock deletion
  }
}

// Riverpod providers for mock service
final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) {
  return MockService.currentUser;
});

final receiptsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return MockService.getReceipts();
});

final refundsProvider = StateProvider<List<Map<String, dynamic>>>((ref) {
  return MockService.getRefunds();
}); 