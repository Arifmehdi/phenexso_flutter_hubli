import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart'; // Adjust the import path as necessary

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    // fetchProducts(); // Removed: Fetching should be triggered by widget lifecycle
  }

  Future<void> fetchProducts({String? categorySlug}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String url;
      if (categorySlug != null) {
        url = 'https://hublibd.com/api/products/by-slug/$categorySlug';
      } else {
        url = 'https://hublibd.com/api/products';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> productJsonList = responseData['data'];
          _products = productJsonList
              .map((json) => Product.fromJson(json))
              .toList();
        } else {
          _errorMessage =
              'Failed to parse products: "data" key not found or not a list.';
        }
      } else {
        _errorMessage = 'Failed to load products: ${response.statusCode}';
      }
    } catch (error) {
      _errorMessage = 'Error fetching products: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategorySlug(String slug) async {
    await fetchProducts(categorySlug: slug);
  }

  // Method to get a product by ID (useful for detail screen)
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }
}

// Add a fromJson factory method to your Product model
// This should ideally be in product.dart, but adding here for context
/*
extension ProductExtension on Product {
  static Product fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(), // Ensure id is string
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? ['assets/images/placeholder.png']), // Handle missing or null imageUrls
      category: json['category'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0, // Handle missing or null rating
    );
  }
}
*/
