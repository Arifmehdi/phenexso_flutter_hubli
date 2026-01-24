import 'package:flutter/material.dart';
import 'package:hubli/data/placeholder_data.dart';
import 'package:hubli/models/product.dart';
import 'package:hubli/utils/colors.dart'; // Assuming you have a colors utility
import 'package:intl/intl.dart';
import 'package:hubli/widgets/custom_app_bar.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<String> _categories = [];
  String? _selectedCategory;
  TextEditingController _searchController = TextEditingController();
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _categories = dummyProducts.map((product) => product.category).toSet().toList();
    _filteredProducts = dummyProducts; // Initialize with all products
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        searchController: _searchController,
        onSearch: _filterProducts,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) => Padding(
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
                )).toList(),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
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
          ),
        ],
      ),
    );
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = dummyProducts.where((product) {
        final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
        final matchesSearch = _searchController.text.isEmpty ||
            product.name.toLowerCase().contains(_searchController.text.toLowerCase());
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
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported, size: 50),
        ),
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported, size: 50),
        ),
      );
    }
  }

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
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
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
                    NumberFormat.currency(locale: 'en_BD', symbol: 'BDT ').format(product.price),
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
