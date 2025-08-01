import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/core/services/platform_service.dart';
import 'package:vendura/core/providers/items_provider.dart';
import 'package:vendura/core/providers/settings_provider.dart';
import 'package:vendura/core/providers/order_session_provider.dart';
import 'package:vendura/core/providers/orders_provider.dart';
import 'package:vendura/data/models/order.dart';
import 'package:vendura/shared/presentation/widgets/responsive_layout.dart';

import 'package:uuid/uuid.dart';

class OrderScreen extends ConsumerStatefulWidget {
  final String? orderId;
  final bool isNewOrder;

  const OrderScreen({
    super.key,
    this.orderId,
    this.isNewOrder = true,
  });

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final List<OrderItem> _cartItems = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isTicketCreated = false;
  
  // Sample tickets for testing
  final List<Map<String, dynamic>> _sampleTickets = [
    {
      'id': '1',
      'items': [
        {
          'id': 'item1',
          'name': 'Cappuccino',
          'price': 5.99,
          'quantity': 2,
        },
        {
          'id': 'item2',
          'name': 'Croissant',
          'price': 3.99,
          'quantity': 1,
        },
      ],
      'totalAmount': 15.97,
      'status': 'pending',
      'orderType': 'Dine-in',
    },
    {
      'id': '2',
      'items': [
        {
          'id': 'item3',
          'name': 'Latte',
          'price': 4.99,
          'quantity': 1,
        },
        {
          'id': 'item4',
          'name': 'Chocolate Muffin',
          'price': 3.49,
          'quantity': 2,
        },
      ],
      'totalAmount': 11.97,
      'status': 'pending',
      'orderType': 'Takeaway',
    },
  ];
  
  List<String> get categories {
    final items = ref.watch(availableItemsProvider);
    final categories = items.map((item) => item['category'] as String).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  List<Map<String, dynamic>> get filteredItems {
    final items = ref.watch(availableItemsProvider);
    return items.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item['description']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  late ProviderSubscription<int> _sessionSub;

  @override
  void initState() {
    super.initState();
    print('OrderScreen constructor passed orderId: ${widget.orderId}, isNewOrder: ${widget.isNewOrder}');
    print('OrderScreen initState - orderId: ${widget.orderId}, isNewOrder: ${widget.isNewOrder}');
    
    // Listen for session reset
    _sessionSub = ref.listenManual<int>(orderSessionProvider, (prev, next) {
      if (widget.isNewOrder) {
        _resetOrder(); // Only reset if it's a new order
      }
    });

    // If editing an existing order, load its data
    if (!widget.isNewOrder && widget.orderId != null) {
      print('Will load existing order data for: ${widget.orderId}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingOrderData();
      });
    } else {
      print('Not loading existing order data - isNewOrder: ${widget.isNewOrder}, orderId: ${widget.orderId}');
    }
  }

  @override
  void dispose() {
    _sessionSub.close();
    super.dispose();
  }

  void _loadExistingOrderData() {
    if (widget.orderId == null) return;
    
    print('Loading existing order data for: ${widget.orderId}');
    
    try {
      final orderData = ref.read(ordersProvider.notifier).getOrder(widget.orderId!);
      if (orderData != null) {
        print('Order data found: ${orderData.keys}');
        print('Full order data: $orderData');
        
        final items = (orderData['items'] as List<dynamic>?)
            ?.map((e) {
              final itemData = e as Map<String, dynamic>;
              print('Loading item: ${itemData['name']} x${itemData['quantity']}');
              
              // Ensure we have all required fields for OrderItem
              return OrderItem(
                id: itemData['id'] as String,
                name: itemData['name'] as String,
                price: (itemData['price'] as num).toDouble(),
                quantity: itemData['quantity'] as int,
                imageUrl: itemData['imageUrl'] as String?,
                addOns: itemData['addOns'] != null 
                    ? List<Map<String, dynamic>>.from(itemData['addOns'] as List)
                    : null,
                comment: itemData['comment'] as String?,
              );
            })
            .toList();
            
        setState(() {
          _cartItems.clear();
          if (items != null) {
            _cartItems.addAll(items);
            print('Loaded ${_cartItems.length} items into cart');
          }
          _isTicketCreated = true; // Always true when editing existing order
        });
        
        // Show a message to indicate existing order items were loaded
        if (mounted && _cartItems.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded existing order with ${_cartItems.length} items'),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('No order data found for: ${widget.orderId}');
        print('Available orders: ${ref.read(ordersProvider).map((o) => o['id']).toList()}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load existing order data'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error loading order data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetOrder() {
    setState(() {
      _cartItems.clear();
      _isTicketCreated = false;
      _selectedCategory = 'All';
      _searchQuery = '';
    });
  }

  void _handleNewTicket() {
    setState(() {
      _cartItems.clear();
      _isTicketCreated = false;
    });
    ref.read(orderSessionProvider.notifier).state++;
  }

  void _handleUpdateTicket() async {
    if (!_isTicketCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active ticket to update'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to order details for editing
    final result = await Navigator.pushNamed(
      context,
      '/order-details',
      arguments: {
        'cartItems': _cartItems,
        'totalAmount': totalAmount,
        'isEditing': true,
      },
    );

    if (result != null && mounted) {
      setState(() {
        // Update the order with the edited details
        final updatedOrder = result as Map<String, dynamic>;
        _cartItems.clear();
        _cartItems.addAll(List<OrderItem>.from(updatedOrder['items']));
      });
    }
  }

  void _handleDeleteTicket() {
    if (!_isTicketCreated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active ticket to delete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: const Text('Are you sure you want to delete this ticket?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _cartItems.clear();
                _isTicketCreated = false;
              });
              ref.read(orderSessionProvider.notifier).state++;
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: widget.isNewOrder ? 'New Ticket' : 'Update Ticket',
        backgroundColor: widget.isNewOrder ? null : Colors.blue.shade50,
        actions: [
          if (!widget.isNewOrder && widget.orderId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ID: ${widget.orderId}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_cartItems.length}',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: _showUserProfile,
            icon: const Icon(Icons.person),
            tooltip: 'User Profile',
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Update Mode Banner
          if (!widget.isNewOrder && _cartItems.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                border: Border(
                  bottom: BorderSide(color: Colors.blue.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit_note, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Updating Order: ${_cartItems.length} existing items loaded',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Category and Search Bar
          _buildCategoryAndSearchBar(),
          
          // Product Grid
          Expanded(
            child: _buildMobileProductList(),
          ),
        ],
      ),
      floatingActionButton: _cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showCartSheet,
              icon: Icon(widget.isNewOrder ? Icons.shopping_cart : Icons.edit),
              label: Text('${widget.isNewOrder ? "Cart" : "Update"} (${_cartItems.length})  |  \$${totalAmount.toStringAsFixed(2)}'),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              heroTag: 'order_fab',
            )
          : null,
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: widget.isNewOrder ? 'New Ticket' : 'Update Ticket',

        actions: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_cartItems.length}',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: _showUserProfile,
            icon: const Icon(Icons.person),
            tooltip: 'User Profile',
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Product Grid
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildCategoryAndSearchBar(),
                Expanded(
                  child: _buildTabletProductList(),
                ),
              ],
            ),
          ),
          
          // Right side - Cart
          if (_cartItems.isNotEmpty)
            Expanded(
              flex: 1,
              child: _buildCartSidebar(),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      appBar: ResponsiveAppBar(
        title: widget.isNewOrder ? 'New Ticket' : 'Update Ticket',

        actions: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_cartItems.length}',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          IconButton(
            onPressed: _showUserProfile,
            icon: const Icon(Icons.person),
            tooltip: 'User Profile',
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - Product Grid
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildCategoryAndSearchBar(),
                Expanded(
                  child: _buildDesktopProductList(),
                ),
              ],
            ),
          ),
          
          // Right side - Cart
          if (_cartItems.isNotEmpty)
            Expanded(
              flex: 1,
              child: _buildCartSidebar(),
            ),
        ],
      ),
    );
  }

  Widget _buildCreateTicketPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Create a ticket to start ordering',
            style: AppTheme.titleMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          ElevatedButton.icon(
            onPressed: _createTicket,
            icon: const Icon(Icons.add),
            label: const Text('Create Ticket'),
            style: AppTheme.primaryButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAndSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spacingS),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[100],
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProductList() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildCompactProductCard(item);
      },
    );
  }

  Widget _buildTabletProductList() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildCompactProductCard(item);
      },
    );
  }

  Widget _buildDesktopProductList() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildCompactProductCard(item);
      },
    );
  }

  Widget _buildCartSidebar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          // Cart Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
                         child: Row(
               children: [
                 Icon(
                   widget.isNewOrder ? Icons.shopping_cart : Icons.edit_note,
                   color: Colors.white,
                 ),
                 const SizedBox(width: AppTheme.spacingS),
                 Text(
                   widget.isNewOrder 
                       ? 'Cart (${_cartItems.length})'
                       : 'Update Order (${_cartItems.length})',
                   style: AppTheme.titleMedium.copyWith(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const Spacer(),
                 Text(
                   '\$${totalAmount.toStringAsFixed(2)}',
                   style: AppTheme.titleMedium.copyWith(
                     color: Colors.white,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
               ],
             ),
          ),
          
          // Cart Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return _buildCartItemCard(item);
              },
            ),
          ),
          
          // Checkout Button
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _proceedToOrderDetails,
                icon: Icon(widget.isNewOrder ? Icons.payment : Icons.save),
                label: Text(widget.isNewOrder ? 'Proceed to Payment' : 'Save Changes'),
                style: AppTheme.primaryButtonStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProductCard(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _showAddItemOptions(item),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusMedium),
                    topRight: Radius.circular(AppTheme.radiusMedium),
                  ),
                  child: item['imageUrl'] != null
                      ? Image.network(
                          item['imageUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.coffee,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.coffee,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                            );
                          },
                        )
                      : Icon(
                          Icons.coffee,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                ),
              ),
            ),
            
            // Item Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item['price'].toStringAsFixed(2)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemCard(OrderItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          backgroundImage: item.imageUrl != null 
              ? NetworkImage(item.imageUrl!) 
              : null,
          child: item.imageUrl == null 
              ? Icon(
                  Icons.coffee,
                  color: AppTheme.primaryColor,
                  size: 20,
                ) 
              : null,
        ),
        title: Text(
          item.name,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '\$${item.price.toStringAsFixed(2)} each',
          style: AppTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _decreaseItemQuantity(item),
              icon: const Icon(Icons.remove, size: 20),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
            Text(
              '${item.quantity}',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => _increaseItemQuantity(item),
              icon: const Icon(Icons.add, size: 20),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
           IconButton(
             onPressed: () => _removeItem(item),
             icon: const Icon(Icons.delete, size: 20, color: Colors.red),
             tooltip: 'Remove item',
             constraints: const BoxConstraints(
               minWidth: 32,
               minHeight: 32,
             ),
           ),
          ],
        ),
      ),
    );
  }

  // Remove an item from the cart entirely
  void _removeItem(OrderItem item) {
    setState(() {
      _cartItems.remove(item);
    });
  }

  void _createTicket() {
    setState(() {
      _isTicketCreated = true;
    });
  }

  void _showAddItemOptions(Map<String, dynamic> item, {OrderItem? existingItem}) {
    final List<Map<String, dynamic>> addOns = (item['addOns'] as List<dynamic>? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    if (addOns.isEmpty) {
      _addItemToCart(item);
      return;
    }

    // Prepare selection and comment for editing
    final Map<Map<String, dynamic>, int> selected = {};
    final commentCtrl = TextEditingController(text: existingItem?.comment ?? '');
    // Pre-populate existing add-ons if editing
    if (existingItem != null && existingItem.addOns != null) {
      for (var add in existingItem.addOns!) {
        final def = addOns.firstWhere((a) => a['id'] == add['id']);
        selected[def] = add['quantity'] as int;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(builder: (context, setModalState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Select Add-Ons for ${item['name']}',
                    style: AppTheme.titleMedium,
                  ),
                ),
                ...addOns.map((addon) {
                  final qty = selected[addon] ?? 0;
                  final isChecked = qty > 0;
                  return ListTile(
                    leading: Checkbox(
                      value: isChecked,
                      onChanged: (v){
                        setModalState((){
                          if(v==true){
                            selected[addon]=1; // default 1
                          }else{
                            selected.remove(addon);
                          }
                        });
                      },
                    ),
                    title: Text('${addon['name']} (+\$${(addon['price'] as num).toStringAsFixed(2)})'),
                    trailing: isChecked ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children:[
                        IconButton(icon:const Icon(Icons.remove,size:18),onPressed:(){
                          setModalState((){
                            final current=selected[addon]??1;
                            if(current>1){selected[addon]=current-1;}
                          });
                        }),
                        Text('$qty'),
                        IconButton(icon:const Icon(Icons.add,size:18),onPressed:(){
                          setModalState((){selected[addon]=(selected[addon]??1)+1;});
                        }),
                      ]) : null,
                  );
                }).toList(),
                const Divider(),
                TextField(
                  controller: commentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppTheme.primaryButtonStyle,
                      onPressed: () {
                        Navigator.pop(context);
                        final processedAddOns = selected.entries.map((e) {
                          final m = Map<String, dynamic>.from(e.key);
                          m['quantity'] = e.value;
                          return m;
                        }).toList();
                        // Remove old item when editing
                        if (existingItem != null) {
                          setState(() {
                            _cartItems.removeWhere((ci) => ci.id == existingItem.id);
                          });
                        }
                        _addItemToCart(item, selectedAddOns: processedAddOns, comment: commentCtrl.text.trim());
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }

  void _addItemToCart(Map<String, dynamic> item, {List<Map<String, dynamic>> selectedAddOns = const [], String? comment}) {
    _isTicketCreated = true;

    final existingItemIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.name == item['name'] && (cartItem.addOns?.isEmpty ?? true) == selectedAddOns.isEmpty,
    );

    double basePrice = (item['price'] as num).toDouble();
    double addOnsPrice = selectedAddOns.fold(0.0, (sum, a) {
      final qty = (a['quantity'] as int?) ?? 1;
      return sum + ((a['price'] as num).toDouble() * qty);
    });

    setState(() {
      if (existingItemIndex != -1) {
        // Update existing item quantity
        final existingItem = _cartItems[existingItemIndex];
        _cartItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        // Add new item with potential add-ons cost included in price
        _cartItems.add(OrderItem(
          id: const Uuid().v4(),
          name: item['name'],
          price: basePrice + addOnsPrice,
          quantity: 1,
          imageUrl: item['imageUrl'] as String?,
          addOns: selectedAddOns.isEmpty ? null : selectedAddOns,
          comment: (comment?.isEmpty ?? true) ? null : comment,
        ));
      }
    });
  }

  void _increaseItemQuantity(OrderItem item) {
    setState(() {
      final index = _cartItems.indexOf(item);
      if (index != -1) {
        _cartItems[index] = item.copyWith(
          quantity: item.quantity + 1,
        );
      }
    });
  }

  void _decreaseItemQuantity(OrderItem item) {
    setState(() {
      if (item.quantity > 1) {
        final index = _cartItems.indexOf(item);
        if (index != -1) {
          _cartItems[index] = item.copyWith(
            quantity: item.quantity - 1,
          );
        }
      } else {
        _cartItems.remove(item);
      }
    });
  }

  void _proceedToOrderDetails() {
    // If we're editing an existing order, save the changes first
    if (!widget.isNewOrder && widget.orderId != null) {
      _saveOrderChanges();
    } else {
      // Navigate to order details screen for new orders
      Navigator.pushNamed(
        context,
        '/order-details',
        arguments: {
          'cartItems': _cartItems,
          'totalAmount': totalAmount,
        },
      );
    }
  }

  void _saveOrderChanges() async {
    if (widget.orderId == null) return;

    // Update the existing order with new items
    final updatedOrderData = {
      'items': _cartItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    try {
      await ref.read(ordersProvider.notifier).updateOrder(widget.orderId!, updatedOrderData);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to main screen and show orders tab
        Navigator.pop(context);
        // Navigate to main screen with orders tab selected
        Navigator.pushReplacementNamed(
          context, 
          '/main',
          arguments: {'initialTabIndex': 2}, // Orders tab
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUserProfile() {
    // Navigate to the dedicated profile screen via the central router
    Navigator.pushNamed(context, '/profile');
  }

  void _showSettings() {
    // Navigate to the main settings screen via the central router
    Navigator.pushNamed(context, '/settings');
  }

  // Add method to show ongoing orders
  void _showOngoingOrdersMenu() {
    // Use ref.watch to always get the latest state
    final orders = ref.watch(ongoingOrdersProvider);
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
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.builder(
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
              ),
            ],
          ),
        );
      },
    );
  }
  // Delete the entire order/ticket
  void _deleteTicket() async {
    print('Delete ticket called');
    // Always try to cancel if there is an orderId
    if (widget.orderId != null) {
      print('Cancelling order: ${widget.orderId}');
      await ref.read(ordersProvider.notifier).cancelOrder(widget.orderId!);
      ref.read(orderSessionProvider.notifier).state++;
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    } else {
      print('Resetting order (no orderId)');
      _resetOrder();
    }
  }

  // Show cart items in a bottom sheet for mobile
  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Cart', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                // Use StatefulBuilder for dynamic updates
                StatefulBuilder(
                  builder: (context, setModalState) {
                    return Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                backgroundImage: item.imageUrl != null 
                                    ? NetworkImage(item.imageUrl!) 
                                    : null,
                                child: item.imageUrl == null 
                                    ? const Icon(Icons.shopping_cart, color: AppTheme.primaryColor)
                                    : null,
                              ),
                              title: Text(item.name),
                              subtitle: Text('\$${item.price.toStringAsFixed(2)} each'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      setModalState(() {
                                        if (item.quantity > 1) {
                                          _cartItems[index] = item.copyWith(quantity: item.quantity - 1);
                                        }
                                      });
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.remove),
                                  ),
                                  Text('${item.quantity}'),
                                  IconButton(
                                    onPressed: () {
                                      setModalState(() {
                                        _cartItems[index] = item.copyWith(quantity: item.quantity + 1);
                                      });
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.add),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setModalState(() {
                                        _cartItems.removeAt(index);
                                      });
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Remove and open edit modal
                                      setModalState(() {
                                        _cartItems.removeAt(index);
                                      });
                                      setState(() {});
                                      Navigator.pop(context);
                                      _editCartItem(item);
                                    },
                                    icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _proceedToOrderDetails();
                      },
                      style: AppTheme.primaryButtonStyle,
                      child: Text(widget.isNewOrder ? 'Proceed to Checkout' : 'Save Changes'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Edit an existing cart item by reopening add-ons sheet
  void _editCartItem(OrderItem item) {
    final baseItem = ref.read(availableItemsProvider).firstWhere((prod) => prod['name'] == item.name);
    _showAddItemOptions(baseItem, existingItem: item);
  }

  // Navigate back to the main screen keeping current ticket intact if possible
  void _goBackToMain() {
    if (!widget.isNewOrder && _cartItems.isNotEmpty) {
      // Show confirmation dialog when editing
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('Do you want to save your changes before leaving?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/main',
                  (route) => false,
                );
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _saveOrderChanges();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } else {
      Navigator.popUntil(context, ModalRoute.withName('/main'));
    }
  }
}