import 'package:flutter/material.dart';
import 'package:khat_husseini/widgets/cart/cart_item_widget.dart';
import '../models/cart_item_model.dart';
import '../services/database_helper.dart';
import '../services/shared_prefs_helper.dart';
import '../widgets/cart/empty_cart_widget.dart';
import '../widgets/cart/cart_bottom_bar.dart';
import '../widgets/cart/checkout_dialog.dart';
import '../widgets/cart/clear_cart_dialog.dart';
import 'main_navigation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final SharedPrefsHelper _prefsHelper = SharedPrefsHelper();

  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void refreshCart() {
    if (mounted) {
      _loadCartItems();
    }
  }

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> _loadCartItems() async {
    setState(() => _isLoading = true);

    try {
      final items = await _getCartItems();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading cart: $e');
    }
  }

  Future<List<CartItem>> _getCartItems() async {
    // First try to get cart items from shared preferences
    var items = await _prefsHelper.getCartItems();

    // If no items in shared prefs or list is empty, try database
    if (items.isEmpty) {
      items = await _databaseHelper.getCartItems();

      // Save to shared preferences for future use
      if (items.isNotEmpty) {
        await _prefsHelper.saveCartItems(items);
      }
    }

    return items;
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeItem(item);
      return;
    }

    try {
      await _databaseHelper.updateCartItemQuantity(item.id, newQuantity);
      await _syncCartData();
      await _loadCartItems();
      _showSuccessSnackBar('Quantity updated');
    } catch (e) {
      _showErrorSnackBar('Error updating quantity: $e');
    }
  }

  Future<void> _removeItem(CartItem item) async {
    try {
      await _databaseHelper.removeFromCart(item.id);
      await _syncCartData();
      await _loadCartItems();
      _showInfoSnackBar('${item.title} removed from cart');
    } catch (e) {
      _showErrorSnackBar('Error removing item: $e');
    }
  }

  Future<void> _clearCart() async {
    final confirmed = await _showClearCartDialog();

    if (confirmed == true) {
      try {
        await _databaseHelper.clearCart();
        await _prefsHelper.clearCart();
        await _loadCartItems();
        _showInfoSnackBar('Cart cleared');
      } catch (e) {
        _showErrorSnackBar('Error clearing cart: $e');
      }
    }
  }

  Future<void> _syncCartData() async {
    final items = await _databaseHelper.getCartItems();
    await _prefsHelper.saveCartItems(items);
  }

  Future<void> _proceedToCheckout() async {
    if (_cartItems.isEmpty) {
      _showInfoSnackBar('Your cart is empty');
      return;
    }

    final shouldProceed = await _showCheckoutDialog();

    if (shouldProceed == true) {
      await _clearCart();
      _showSuccessSnackBar('Order placed successfully! (Demo)');
    }
  }

  Future<bool?> _showClearCartDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => const ClearCartDialog(),
    );
  }

  Future<bool?> _showCheckoutDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => CheckoutDialog(totalAmount: totalAmount),
    );
  }

  void _navigateToBrowse() {
    final mainNavState =
        context.findAncestorStateOfType<MainNavigationScreenState>();
    mainNavState?.navigateToTab(0);
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message, Colors.red);
  }

  void _showSuccessSnackBar(String message) {
    _showSnackBar(message, Colors.green);
  }

  void _showInfoSnackBar(String message) {
    _showSnackBar(message, Colors.orange);
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        children: [
          Icon(Icons.shopping_cart, color: Colors.cyan[800]),
          const SizedBox(width: 4),
          Text(
            "Shopping Cart",
            style: TextStyle(
              color: Colors.cyan[800],
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
        ],
      ),
      actions:
          _cartItems.isNotEmpty
              ? [
                IconButton(
                  icon: Icon(Icons.delete_sweep, color: Colors.cyan[800]),
                  onPressed: _clearCart,
                  tooltip: 'Clear Cart',
                ),
              ]
              : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.teal));
    }

    if (_cartItems.isEmpty) {
      return EmptyCartWidget(onBrowsePressed: _navigateToBrowse);
    }

    return _buildCartContent();
  }

  Widget _buildCartContent() {
    return RefreshIndicator(
      onRefresh: _loadCartItems,
      color: Colors.teal,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cartItems.length,
        itemBuilder: (context, index) {
          final item = _cartItems[index];
          return CartItemWidget(
            item: item,
            onQuantityChanged:
                (newQuantity) => _updateQuantity(item, newQuantity),
            onRemove: () => _removeItem(item),
          );
        },
      ),
    );
  }

  Widget? _buildBottomNavigationBar() {
    if (_cartItems.isEmpty) return null;

    return CartBottomBar(
      totalAmount: totalAmount,
      itemCount: _cartItems.length,
      onCheckoutPressed: _proceedToCheckout,
    );
  }
}
