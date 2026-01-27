import 'package:flutter/material.dart';
import 'package:hubli/data/placeholder_data.dart';
import 'package:hubli/models/product.dart';
import 'package:intl/intl.dart';
import 'package:hubli/widgets/custom_app_bar.dart';
import 'dart:async'; // Import for Timer

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
        // Account - Not implemented yet, show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Screen (Not Implemented)')),
        );
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
            GestureDetector(
              onPanDown: (_) => _pauseAutoSlide(),
              onPanEnd: (_) => _resumeAutoSlide(),
              onPanCancel: () => _resumeAutoSlide(),
              child: SizedBox(
                height: 200.0, // Fixed height for the slider
                child: PageView.builder(
                  controller: _pageController, // Attach controller
                  itemCount: _sliderImages.length,
                  itemBuilder: (context, index) {
                    return Image.asset(_sliderImages[index], fit: BoxFit.cover);
                  },
                ),
              ),
            ),
            Padding(
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
