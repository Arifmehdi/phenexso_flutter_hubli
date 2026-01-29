import 'package:flutter/material.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:hubli/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedIndex = 2; // Index for Cart

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // Do nothing if the current tab is re-selected
    }
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/'); // Home
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RFQ Screen (Not Implemented)')),
        );
        break;
      case 2:
        // Already on Cart screen
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/shipping-address'); // Shipping
        break;
      case 4:
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isAuthenticated) {
          Navigator.of(context).pushNamed('/account');
        } else {
          Navigator.of(context).pushNamed('/login');
        }
        break;
    }
  }

  // Dummy controller for CustomAppBar in CartScreen
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildProductImage(List<String> imageUrls) {
    if (imageUrls.first.startsWith('assets/')) {
      return Image.asset(
        imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported, size: 20),
        ),
      );
    } else {
      return Image.network(
        imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported, size: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        searchController: _searchController, // Use dummy controller
        onSearch: () {}, // Dummy callback
      ),
      body: cart.itemCount == 0
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 22, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.itemCount + 1, // Add 1 for the total/order card
                    itemBuilder: (ctx, i) {
                      if (i == cart.itemCount) {
                        return Card(
                          margin: const EdgeInsets.all(15),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  'Total',
                                  style: TextStyle(fontSize: 20),
                                ),
                                const Spacer(),
                                Chip(
                                  label: Text(
                                    NumberFormat.currency(locale: 'en_BD', symbol: '৳ ').format(cart.totalAmount),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                                    ),
                                  ),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                                TextButton(
                                  child: const Text('ORDER NOW'),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/order-confirmation');
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      }
                      final cartItem = cart.items.values.toList()[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/product-detail',
                            arguments: cartItem.product,
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: _buildProductImage(cartItem.product.imageUrls),
                                ),
                              ),
                                                          title: Text(cartItem.product.name),
                                                          subtitle: Text(
                                                              'Price: \$${cartItem.product.price.toStringAsFixed(2)}'),
                                                          trailing: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              IconButton(
                                                                icon: const Icon(Icons.remove),
                                                                onPressed: () {
                                                                  Provider.of<CartProvider>(context,
                                                                          listen: false)
                                                                      .decreaseQuantity(cartItem.product.id);
                                                                },
                                                              ),
                                                              Text('${cartItem.quantity}'),
                                                              IconButton(
                                                                icon: const Icon(Icons.add),
                                                                onPressed: () {
                                                                  Provider.of<CartProvider>(context,
                                                                          listen: false)
                                                                      .increaseQuantity(cartItem.product.id);
                                                                },
                                                              ),
                                                            ],
                                                          ),                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'RFQ',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) => Stack(
                children: [
                  const Icon(Icons.shopping_cart),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Shipping',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}