import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart';
import 'package:vendura/core/providers/items_provider.dart';
import 'package:vendura/core/providers/settings_provider.dart';
import 'package:vendura/core/providers/order_session_provider.dart';
import 'package:vendura/data/models/order.dart';

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
    // Listen for session reset
    _sessionSub = ref.listenManual<int>(orderSessionProvider, (prev, next) {
      _resetOrder();
    });
  }

  @override
  void dispose() {
    _sessionSub.close();
    super.dispose();
  }

  void _resetOrder() {
    setState(() {
      _cartItems.clear();
      _isTicketCreated = false;
      _selectedCategory = 'All';
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.receipt, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Ticket'),
            const SizedBox(width: 8),
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
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showUserProfile,
            icon: const Icon(Icons.person),
            tooltip: 'User Profile',
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.more_vert),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket & Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _isTicketCreated 
                            ? null 
                            : LinearGradient(
                                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: _isTicketCreated ? Colors.grey[400] : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: _isTicketCreated ? null : [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isTicketCreated ? null : () {
                          setState(() => _isTicketCreated = true);
                        },
                        icon: Icon(
                          _isTicketCreated ? Icons.check_circle : Icons.receipt_long,
                          size: 20,
                        ),
                        label: Text(
                          _isTicketCreated ? 'Ticket Created ✓' : 'Create New Ticket',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menu Items',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            '${filteredItems.length} items available',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: _isTicketCreated && _cartItems.isNotEmpty 
                              ? LinearGradient(
                                  colors: [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: _isTicketCreated && _cartItems.isNotEmpty ? null : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isTicketCreated && _cartItems.isNotEmpty ? [
                            BoxShadow(
                              color: AppTheme.successGreen.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ] : null,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _isTicketCreated && _cartItems.isNotEmpty ? _proceedToOrderDetails : null,
                          icon: Icon(
                            _cartItems.isNotEmpty ? Icons.shopping_cart_checkout : Icons.shopping_cart_outlined,
                            size: 18,
                          ),
                          label: Text(
                            _cartItems.isNotEmpty 
                                ? 'Cart (${_cartItems.length}) - \$${totalAmount.toStringAsFixed(2)}'
                                : 'Cart (${_cartItems.length})',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search menu items...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Category Filter Chips
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: AppTheme.primaryColor,
                      checkmarkColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      elevation: isSelected ? 3 : 1,
                      pressElevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Products List
            Expanded(
              child: _isTicketCreated
                  ? (isMobile ? _buildMobileProductList() : _buildDesktopProductList())
                  : Center(
                      child: Text(
                        'Please create a ticket to start ordering.',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 18,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: isMobile && _cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _proceedToOrderDetails,
              icon: const Icon(Icons.shopping_cart),
              label: Text('Cart (${_cartItems.length})'),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            )
          : null,
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

  Widget _buildCompactProductCard(Map<String, dynamic> item) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: _isTicketCreated ? () => _showProductDetails(item) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(item['imageUrl'] ?? 'https://via.placeholder.com/80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Product Name
              Text(
                item['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Price
              Text(
                '\$${(item['price'] as num).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              // Add-ons indicator
              if ((item['addOns'] as List<Map<String, dynamic>>? ?? []).isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(item['addOns'] as List<Map<String, dynamic>>? ?? []).length} add-ons',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildProductDetailsSheet(item),
    );
  }

  Widget _buildProductDetailsSheet(Map<String, dynamic> item) {
    final addOns = item['addOns'] as List<Map<String, dynamic>>? ?? [];
    final availableAddOns = addOns.where((addon) => addon['isAvailable'] == true).toList();
    final selectedAddOns = <Map<String, dynamic>>{};
    int quantity = 1;
    String comment = '';

    return StatefulBuilder(
      builder: (context, setState) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['imageUrl'] ?? 'https://via.placeholder.com/60'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '\$${(item['price'] as num).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Add-ons Section
            if (availableAddOns.isNotEmpty) ...[
              Text(
                'Customizations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: availableAddOns.length,
                  itemBuilder: (context, index) {
                    final addOn = availableAddOns[index];
                    final isSelected = selectedAddOns.contains(addOn);
                    
                    return CheckboxListTile(
                      title: Text(addOn['name']),
                      subtitle: Text('\$${addOn['price']} - ${addOn['category']}'),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            selectedAddOns.add(addOn);
                          } else {
                            selectedAddOns.remove(addOn);
                          }
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Quantity Section
            Text(
              'Quantity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() => quantity--);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => quantity++);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Comment Section
            Text(
              'Comment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => comment = value,
              decoration: const InputDecoration(
                hintText: 'Enter comment',
                border: UnderlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _addItemToCart(item, selectedAddOns.toList(), quantity, comment);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItemToCart(
    Map<String, dynamic> item,
    List<Map<String, dynamic>> selectedAddOns,
    int quantity,
    String comment,
  ) {
    // Calculate total price including add-ons
    double totalPrice = (item['price'] as num).toDouble();
    for (final addOn in selectedAddOns) {
      totalPrice += (addOn['price'] as num).toDouble();
    }
    
    // Add to cart
    setState(() {
      _cartItems.add(OrderItem(
        id: item['id'],
        name: item['name'],
        price: totalPrice,
        quantity: quantity,
        imageUrl: item['imageUrl'],
        addOns: selectedAddOns,
        comment: comment.isNotEmpty ? comment : null,
      ));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item['name']} added to cart'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _openTickets() {
    // TODO: Implement open tickets functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Open tickets functionality coming soon'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _proceedToOrderDetails() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add items to cart before proceeding'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: {
        'cartItems': _cartItems,
        'totalAmount': totalAmount,
      },
    );
  }

  void _showUserProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _showSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _showSearch() {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Search functionality coming soon'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 