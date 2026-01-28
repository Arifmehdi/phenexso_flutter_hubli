import 'package:flutter/material.dart';
import 'package:hubli/data/placeholder_data.dart';
import 'package:hubli/models/product.dart';
import 'package:intl/intl.dart';
import 'package:hubli/widgets/custom_app_bar.dart';
import 'dart:async'; // Import for Timer
import 'package:provider/provider.dart';
import 'package:hubli/providers/auth_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<String> _categories = [];
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  // For auto-sliding image carousel
  final PageController _pageController = PageController();
  late Timer _timer;
  int _currentPage = 0;

  final List<String> _sliderImages = [
    'assets/images/slider/fruit.png',
    'assets/images/slider/fresh.png',
    'assets/images/slider/dairy.png',
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'All Category', 'icon': Icons.category, 'onTap': () => print('All Category tapped')},
    {'title': 'RFQ', 'icon': Icons.assignment, 'onTap': () => print('RFQ tapped')},
    {'title': 'Ship For Me', 'icon': Icons.local_shipping, 'onTap': () => print('Ship For Me tapped')},
    {'title': 'Cost Calculator', 'icon': Icons.calculate, 'onTap': () => print('Cost Calculator tapped')},
    {'title': 'Wishlist', 'icon': Icons.favorite_border, 'onTap': () => print('Wishlist tapped')},
  ];

  int _selectedIndex = 0; // New state variable for bottom navigation

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
        // RFQ - Not implemented yet, show a snackbar
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
        if (authProvider.isAuthenticated) {
          Navigator.of(context).pushNamed('/account');
        } else {
          Navigator.of(context).pushNamed('/login');
        }
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _categories = dummyProducts
        .map((product) => product.category)
        .toSet()
        .toList();
    _filteredProducts = dummyProducts; // Initialize with all products

    // Listen to page changes to keep _currentPage in sync
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });

    _startAutoSlide();
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
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        searchController: _searchController,
        onSearch: _filterProducts,
      ),
      body: SingleChildScrollView(
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
                        children: dummyProducts.take(5).map((product) { // Taking 5 products for demonstration
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
                                          child: Image.asset(
                                            product.imageUrl,
                                            fit: BoxFit.cover, // Fill the square space
                                            width: double.infinity,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Center(child: Icon(Icons.image_not_supported, size: 40)),
                                          ),
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
                                              children: const [
                                                Icon(Icons.star, color: Colors.amber, size: 14), // Reduced icon size (Step 11)
                                                Text('5 | 4k sold', style: TextStyle(fontSize: 12.0)),
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

            Padding( // This is the category chips section
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                                _filterProducts();
                              });
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
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
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ProductGridItem(product: product);
              },
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

  void _filterProducts() {
    setState(() {
      _filteredProducts = dummyProducts.where((product) {
        final matchesCategory =
            _selectedCategory == null || product.category == _selectedCategory;
        final matchesSearch =
            _searchController.text.isEmpty ||
            product.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
        return matchesCategory && matchesSearch;
      }).toList();
    });
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

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image_not_supported, size: 50)),
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.image_not_supported, size: 50)),
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
                child: _buildProductImage(product.imageUrl),
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
                      symbol: 'BDT ',
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
