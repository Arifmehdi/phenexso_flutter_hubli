import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../widgets/custom_app_bar.dart'; // Assuming this exists for consistency
import '../providers/auth_provider.dart'; // Add this import
import '../providers/cart_provider.dart'; // Add this import

class CategoryProductsScreen extends StatefulWidget {
  static const routeName = '/category-products';
  final String categorySlug;
  final String categoryName;

  const CategoryProductsScreen({
    Key? key,
    required this.categorySlug,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  late TextEditingController _searchController;
  List<Product> _filteredProducts = []; // To store filtered products

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Fetch products when the screen initializes
    Future.delayed(Duration.zero).then((_) {
      Provider.of<ProductProvider>(
        context,
        listen: false,
      ).fetchProductsByCategorySlug(widget.categorySlug).then((_) {
        _filterProducts(); // Initial filtering after products are fetched
      });
    });

    _searchController.addListener(
      _filterProducts,
    ); // Listen to search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts); // Remove listener
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // This screen does not manage _selectedIndex directly, but navigates
    switch (index) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1:
        // RFQ - Not implemented yet, show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RFQ Screen (Not Implemented)')),
        );
        break;
      case 2:
        Navigator.of(context).pushNamed('/cart'); // Cart
        break;
      case 3:
        Navigator.of(context).pushNamed('/shipping-address'); // Shipping
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

  void _filterProducts() {
    final productProvider = Provider.of<ProductProvider>(
      context,
      listen: false,
    );
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = productProvider.products.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.categoryName,
        searchController: _searchController,
        onSearch: _filterProducts,
        showBackButton: true, // Show back button
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (productProvider.errorMessage != null) {
            return Center(
              child: Text('Error: ${productProvider.errorMessage}'),
            );
          }
          // Display filtered products, or all products if no search query
          final productsToDisplay = _searchController.text.isEmpty
              ? productProvider.products
              : _filteredProducts;

          if (productsToDisplay.isEmpty) {
            return const Center(
              child: Text('No products found for this category or search.'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65, // Adjust to make products look larger
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: productsToDisplay.length,
            itemBuilder: (ctx, i) {
              final product = productsToDisplay[i];
              return GestureDetector(
                onTap: () {
                  Navigator.of(
                    context,
                  ).pushNamed('/product-detail', arguments: product);
                },
                child: ProductItem(product: product),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
        currentIndex:
            0, // Always highlight Home as this is a sub-route of the main product flow
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
      ),
    );
  }
}

// Reusing a simplified product item for display,
// you might have a more complex one in your project.
class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              product.imageUrls[0],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              product.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
