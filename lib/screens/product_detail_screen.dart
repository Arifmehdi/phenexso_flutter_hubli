import 'package:flutter/material.dart';
import 'package:hubli/models/product.dart';
import 'package:hubli/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController(); // Added PageController
  int _currentImageIndex = 0; // Added current image index
  Color _appBarColor = Colors.transparent;
  Color _iconColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _pageController.addListener(() { // Listen to page changes
      setState(() {
        _currentImageIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose(); // Dispose PageController
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      if (offset > 250) {
        if (_appBarColor != Colors.white) {
          setState(() {
            _appBarColor = Colors.white;
            _iconColor = Colors.black;
          });
        }
      } else {
        if (_appBarColor != Colors.transparent) {
          setState(() {
            _appBarColor = Colors.transparent;
            _iconColor = Colors.white;
          });
        }
      }
    }
  }

  Widget _buildIcon(IconData icon, VoidCallback onPressed, {int? itemCount}) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: _appBarColor == Colors.transparent ? Colors.grey.withOpacity(0.5) : Colors.transparent, // Changed to ash with transparency
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          IconButton(
            icon: Icon(icon, color: _iconColor),
            onPressed: onPressed,
          ),
          if (itemCount != null && itemCount > 0)
            Positioned(
              right: 5,
              top: 5,
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
                  itemCount.toString(),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context); // Listen to cart changes
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: _appBarColor,
            elevation: _appBarColor == Colors.white ? 4 : 0,
            leading: _buildIcon(Icons.arrow_back, () => Navigator.of(context).pop()),
            actions: [
              _buildIcon(Icons.favorite_border, () { // Wishlist icon
                // TODO: Implement wishlist functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wishlist functionality not implemented yet.')),
                );
              }),
              _buildIcon(Icons.share, () { // Share icon
                // TODO: Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share functionality not implemented yet.')),
                );
              }),
              _buildIcon(Icons.shopping_cart, () { // Swapped order
                Navigator.of(context).pushNamed('/cart');
              }, itemCount: cart.itemCount), // Pass cart item count
              _buildIcon(Icons.search, () {}), // Swapped order
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack( // Use Stack to layer PageView and indicator
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.product.imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.product.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
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
                    },
                  ),
                  Positioned( // Pagination indicator
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${widget.product.imageUrls.length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // Thumbnail image strip
                if (widget.product.imageUrls.length > 1)
                  SizedBox(
                    height: 80.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.imageUrls.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                          child: Container(
                            width: 70.0,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: _currentImageIndex == index ? Theme.of(context).primaryColor : Colors.grey,
                                width: _currentImageIndex == index ? 2.0 : 1.0,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: Image.network(
                                widget.product.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(Icons.image_not_supported, size: 20),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
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
                          symbol: '৳ ',
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
                          const Icon(Icons.star, color: Colors.amber, size: 20),
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
                      Html(data: widget.product.description),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // Changed to white
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  cart.addItem(widget.product); // Add to cart before buying
                  Navigator.of(context).pushNamed('/shipping-address');
                },
                child: const Text('Buy Now'),
                style: ElevatedButton.styleFrom(
                  // backgroundColor: const Color(0xFF00883C), // Removed hardcoded color
                  // foregroundColor: Colors.white, // Removed hardcoded color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Added border radius
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8), // Add some space between buttons
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  cart.addItem(widget.product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.product.name} added to cart!'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  // backgroundColor: const Color(0xFFDEFFEC), // Removed hardcoded color
                  // foregroundColor: Colors.black, // Removed hardcoded color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Added border radius
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
