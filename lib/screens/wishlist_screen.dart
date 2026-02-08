import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/wishlist_provider.dart';
import 'package:hubli/models/product.dart';
import 'package:hubli/widgets/custom_app_bar.dart';
import 'package:hubli/providers/auth_provider.dart'; // For bottom nav
import 'package:hubli/providers/cart_provider.dart'; // For bottom nav
import 'package:intl/intl.dart'; // For currency formatting
import 'package:hubli/models/user_role.dart'; // Import UserRole enum

class WishlistScreen extends StatefulWidget {
  static const routeName = '/wishlist';

  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late TextEditingController _searchController;
  int _selectedIndex = 4; // Wishlist might be part of account/profile, or its own tab. Setting to 4 for example, assuming it's the last one.
  // The user asked for "home page wishlist icon click show all wishlist product"
  // so let's set _selectedIndex to highlight the account/profile icon (index 4) if it's there
  // or a new wishlist icon if we add one to the main bottom nav.
  // For now, setting it to 4 assuming wishlist is accessible from 'Account' or similar.
  // If the user meant a dedicated wishlist tab in the main nav, we'd adjust the main nav.

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterWishlist); // Listen to search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterWishlist);
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // Do nothing if the current tab is re-selected
    }
    setState(() {
      _selectedIndex = index;
    });

    if (!mounted) return; // Add mounted check here

    // Handle navigation based on index, similar to ProductListScreen
    switch (index) {
      case 0:
        // Navigate to home only if not already on home
        if (ModalRoute.of(context)?.settings.name != '/') {
          Navigator.of(context).pushReplacementNamed('/');
        }
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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!mounted) return; // Re-check mounted after potentially long Provider operation
        if (authProvider.isAuthenticated) {
          if (authProvider.user!.role == UserRole.admin) {
            Navigator.of(context).pushReplacementNamed('/admin-panel'); // Navigate to Admin Panel
          } else {
            Navigator.of(context).pushReplacementNamed('/account'); // Navigate to Account for other roles
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/login'); // Navigate to Login
        }
        break;
    }
  }
  void _filterWishlist() {
    setState(() {
      // Rebuild will trigger the filtering logic in the Consumer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Wishlist',
        searchController: _searchController,
        onSearch: _filterWishlist, // Trigger filtering on search button tap
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          final query = _searchController.text.toLowerCase();
          final filteredWishlist = wishlistProvider.wishlistItems.where((product) {
            return product.name.toLowerCase().contains(query);
          }).toList();

          if (wishlistProvider.wishlistItems.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.'));
          }
          if (filteredWishlist.isEmpty && query.isNotEmpty) {
            return const Center(child: Text('No products found matching your search.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Consistent with CategoryProductsScreen
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filteredWishlist.length,
            itemBuilder: (ctx, i) {
              final product = filteredWishlist[i];
              return WishlistItem(product: product);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // RFQ
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
            icon: Icon(Icons.local_shipping), // Shipping
            label: 'Shipping',
          ),
          const BottomNavigationBarItem(
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

class WishlistItem extends StatelessWidget {
  final Product product;

  const WishlistItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/product-detail',
          arguments: product,
        );
      },
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    product.imageUrls[0],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, child) {
                        return IconButton(
                          icon: Icon(
                            wishlistProvider.isInWishlist(product) ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            wishlistProvider.toggleWishlist(product);
                            if (!context.mounted) return; // Add mounted check here
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(wishlistProvider.isInWishlist(product)
                                    ? '${product.name} added to wishlist!'
                                    : '${product.name} removed from wishlist!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_BD',
                      symbol: '৳ ',
                    ).format(product.price),
                    style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                      onPressed: () {
                        Provider.of<CartProvider>(context, listen: false).addItem(product);
                        if (!context.mounted) return; // Add mounted check here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}