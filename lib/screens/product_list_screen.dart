import 'package:flutter/material.dart';
import 'package:hubli/models/product.dart';
import 'package:intl/intl.dart';
import 'package:hubli/widgets/custom_app_bar.dart';
import 'dart:async'; // Import for Timer
import 'package:provider/provider.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:hubli/providers/product_provider.dart'; // Import ProductProvider
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hubli/providers/category_provider.dart';
import 'package:hubli/models/category.dart';
import 'package:hubli/models/user_role.dart'; // Import UserRole enum

class ProductListScreen extends StatefulWidget {
  final String? categorySlug;
  const ProductListScreen({super.key, this.categorySlug});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();


  // For auto-sliding image carousel
  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPage = 0;

  final List<String> _sliderImages = [
    'assets/images/slider/fruit.png',
    'assets/images/slider/fresh.png',
    'assets/images/slider/dairy.png',
    'assets/images/slider/supply_chain_1.png',
    'assets/images/slider/supply_chain_2.png',
  ];

  List<Map<String, dynamic>> get _menuItems {
    return [
      {'title': 'All Category', 'icon': Icons.category, 'onTap': () => Navigator.of(context).pushNamed('/all-categories')},
      {'title': 'RFQ', 'icon': Icons.assignment, 'onTap': () => print('RFQ tapped')},
      {'title': 'Order Tracking', 'icon': Icons.track_changes, 'onTap': () => Navigator.of(context).pushNamed('/order-tracking')},
      {'title': 'Cost Calculator', 'icon': Icons.calculate, 'onTap': () => Navigator.of(context).pushNamed('/cost-calculator')},
      {'title': 'Wishlist', 'icon': Icons.favorite_border, 'onTap': () => Navigator.of(context).pushNamed('/wishlist')},
    ];
  }

  int _selectedIndex = 0; // New state variable for bottom navigation

  @override
  void initState() {
    super.initState();

    // Defer all initial setup that might cause setState or rebuilds until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start fetching products immediately, potentially filtered by categorySlug
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(
        categorySlug: widget.categorySlug,
      );

      // Listen to page changes to keep _currentPage in sync
      _pageController.addListener(() {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      });

      _startAutoSlide(); // Starts a timer which calls setState
      _searchController.addListener(_filterProducts); // Add listener for live search (calls setState)
    });
  }





  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) { // Check if controller is attached
        if (_currentPage < _sliderImages.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _pauseAutoSlide() {
    _timer.cancel();
  }

  void _resumeAutoSlide() {
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    _searchController.removeListener(_filterProducts); // Remove listener
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // Do nothing if the current tab is re-selected
    }
    setState(() {
      _selectedIndex = index;
    });

    if (!mounted) return; // Ensure widget is still active before navigating

    // Handle navigation based on index
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
          } else if (authProvider.user!.role == UserRole.rider) { // New condition for rider
            Navigator.of(context).pushReplacementNamed('/rider-panel'); // Navigate to Rider Panel
          } else {
            Navigator.of(context).pushReplacementNamed('/seller-panel'); // Navigate to Seller Panel for all other authenticated roles
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/login'); // Navigate to Login if not authenticated
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        searchController: _searchController,
        onSearch: _filterProducts,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.errorMessage != null) {
            return Center(child: Text('Error: ${productProvider.errorMessage}'));
          }

          final products = productProvider.products;

          // Compute categories for display in ChoiceChips
          final displayedCategories = products.map((product) => product.category).toSet().toList();

          // Compute filtered products (only by search query)
          final currentFilteredProducts = products.where((product) {
            final matchesSearch =
                _searchController.text.isEmpty ||
                product.name.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );
            return matchesSearch; // Only search filter applies locally
          }).toList();


          return SingleChildScrollView(
            child: Column(
              children: [
                // Image Slider/Carousel
                Stack(
                  children: [
                    GestureDetector(
                      onPanDown: (_) => _pauseAutoSlide(),
                      onPanEnd: (_) => _resumeAutoSlide(),
                      onPanCancel: () => _resumeAutoSlide(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Reduced vertical padding
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0), // Apply border radius
                          child: SizedBox(
                            height: 180.0, // Reduced height for the slider
                            child: PageView.builder(
                              controller: _pageController, // Attach controller
                              itemCount: _sliderImages.length,
                              itemBuilder: (context, index) {
                                return Image.asset(_sliderImages[index], fit: BoxFit.cover);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 18.0, // Adjusted to be slightly above the bottom of the slider
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicator(),
                      ),
                    ),
                  ],
                ), // Closing bracket for the Stack (slider)

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _menuItems.expand((item) => [ // Use expand to interleave items and spacers
                        Column(
                          children: [
                            SizedBox(
                              width: 60.0, // Reduced width for the box (icon only)
                              height: 60.0, // Make it square
                              child: Card(
                                elevation: 2.0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                child: InkWell(
                                  onTap: item['onTap'],
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Center( // Center the icon within the card
                                    child: Icon(item['icon'], size: 28.0, color: Theme.of(context).primaryColor,), // Icon size adjustment
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4.0), // Space between box and text
                            SizedBox(
                              width: 60.0, // Text width same as box width for alignment
                              height: 28.0, // Fixed height to accommodate 2 lines of text (approx 2 * 10 + some line spacing)
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Text(
                                  item['title'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8.0), // Spacing between items (reduced from 10.0)
                      ]).toList()..removeLast(), // Remove the last SizedBox to avoid trailing space
                    ),
                  ),
                ), // Closing bracket for the new menu section



                // New Banner Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Consistent horizontal padding
                  child: Image.asset( // Removed ClipRRect
                    'assets/images/shop_ad.png', // Assuming this path
                    fit: BoxFit.cover, // Cover the available space
                    width: double.infinity, // Take full width
                    height: 70.0, // Reduced height
                  ),
                ),

                // Deals for you Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row( // New Row for title and arrow icon
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align title left, arrow right
                        children: [
                          const Text(
                            'Deals for you',
                            style: TextStyle(
                              fontSize: 16.0, // Reduced font size
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios), // Icon size is often affected by constraints
                            onPressed: () {
                              // TODO: Implement navigation to a "View All Deals" screen
                              print('View All Deals tapped');
                            },
                            iconSize: 14.0, // Further reduced icon size
                            padding: EdgeInsets.zero, // Remove default padding
                            constraints: const BoxConstraints(), // Remove default constraints
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        height: 220, // Reduced height for the entire section
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: products.take(5).map((product) { // Using 'products'
                              return Padding(
                                padding: const EdgeInsets.only(right: 10.0), // Spacing between cards
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.35, // Reduced width for each card (Step 11)
                                  // Custom product display for "Deals for you"
                                  child: GestureDetector( // Added GestureDetector for navigation
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/product-detail', arguments: product);
                                    },
                                    child: Card(
                                      elevation: 2.0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AspectRatio(
                                            aspectRatio: 1.0, // Ensures a square aspect ratio for the image container
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(8.0),
                                              ),
                                              child: _buildProductImage(product.imageUrls), // Use _buildProductImage
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '৳ ${NumberFormat.currency(locale: 'en_BD', symbol: '').format(product.price)}', // Price with '৳' symbol (Step 10)
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0,
                                                    color: Color(0xFF008739), // Changed to search icon background color (Step 11, but color from current context is red)
                                                  ),
                                                ),
                                                const SizedBox(height: 2.0), // Reduced gap (Step 11)
                                                Row(
                                                  children: [
                                                    Icon(Icons.star, color: Colors.amber, size: 14), // Reduced icon size (Step 11)
                                                    Text('${product.rating.toStringAsFixed(1)} | 4k sold', style: TextStyle(fontSize: 12.0)), // Display rating
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                // Removed Expanded from here
                GridView.builder(
                  shrinkWrap: true, // Make GridView take only necessary space
                  physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.75, // Adjust as needed
                  ),
                  itemCount: currentFilteredProducts.length, // Use currentFilteredProducts
                  itemBuilder: (context, index) {
                    final product = currentFilteredProducts[index]; // Use currentFilteredProducts
                    return ProductGridItem(product: product);
                  },
                ),
              ],
            ),
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

  void _filterProducts() {
    setState(() {
      // Rebuild will trigger the filtering logic in the build method.
    });
  }

  Widget _buildProductImage(List<String> imageUrls) {
    if (imageUrls.first.startsWith('assets/')) {
      return Image.asset(
        imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) =>
            const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 50),
                Text('Failed to load image'),
              ],
            )),
      );
    }
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _sliderImages.length; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 8.0 : 8.0, // Keep same size for simplicity, or make active larger
      decoration: BoxDecoration(
        color: isActive ? Theme.of(context).primaryColor : Colors.grey[400],
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class ProductGridItem extends StatelessWidget {
  final Product product;

  const ProductGridItem({super.key, required this.product});

  Widget _buildProductImage(List<String> imageUrls) {
    if (imageUrls.first.startsWith('assets/')) {
      return Image.asset(
        imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrls.first,
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) =>
            const Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 50),
                Text('Failed to load image'),
              ],
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/product-detail', arguments: product);
      },
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8.0),
                ),
                child: _buildProductImage(product.imageUrls),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_BD',
                      symbol: '৳ ',
                    ).format(product.price),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      Text('${product.rating}'),
                    ],
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