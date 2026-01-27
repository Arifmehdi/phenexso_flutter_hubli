import 'package:flutter/material.dart';
import 'package:hubli/models/product.dart';
import 'package:hubli/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/cart_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedIndex = 0; // Initialize to Home index

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
        Navigator.of(context).pushReplacementNamed('/cart'); // Cart
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed('/shipping-address'); // Shipping
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Screen (Not Implemented)')),
        );
        break;
    }
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 300,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 100,
              color: Colors.grey,
            ),
          ),
        ),
      );
    } else {
      return Image.network(
        imageUrl,
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 300,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 100,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(widget.product.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_BD',
                      symbol: 'BDT ',
                    ).format(widget.product.price),
                    style: TextStyle(
                      fontSize: 24,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        '${widget.product.rating} (${(widget.product.rating * 20).toInt()} reviews)', // Placeholder for review count
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category: ${widget.product.category}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Product Description:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addItem(widget.product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.product.name} added to cart!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColorsPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // RFQ
            label: 'RFQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), // Shipping
            label: 'Shipping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Account
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
      ),
    );
  }
}
