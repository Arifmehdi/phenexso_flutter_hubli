import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hubli/utils/api_constants.dart';
import 'package:hubli/models/product.dart';

class SellerProductService {
  final String? _authToken;

  SellerProductService(this._authToken);

  String? get authToken => _authToken;

  Map<String, String> _getHeaders() {
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<List<Product>> fetchSellerProducts() async {
    final response = await http.get(
      Uri.parse(ApiConstants.sellerProductsEndpoint),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> productsJson = data['data'] ?? [];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load seller products: ${response.statusCode}');
    }
  }

  Future<void> addProduct({
    required String nameEn,
    required String slug,
    required double price,
    required int stock,
    required String categoryId,
    required String descriptionEn,
    required String userId, // Add userId to parameters
    File? image,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.productsEndpoint));
    
    request.headers.addAll(_getHeaders());
    
    request.fields['name_en'] = nameEn;
    request.fields['name_bn'] = nameEn; 
    request.fields['slug'] = slug; // Use passed slug
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['category_id'] = categoryId;
    request.fields['description_en'] = descriptionEn;
    request.fields['description_bn'] = descriptionEn;
    request.fields['addedby_id'] = userId; // Set as login user
    request.fields['seller_id'] = userId;  // Set as login user
    
    request.fields['active'] = '1';

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('featured_image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Add Product Status: ${response.statusCode}');
    debugPrint('Add Product Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add product');
    }
  }

  Future<void> updateProduct({
    required String productId,
    required String nameEn,
    required String slug,
    required double price,
    required int stock,
    required String categoryId,
    required String descriptionEn,
    required String userId,
    File? image,
  }) async {
    // Using POST with _method=PATCH for multipart/form-data compatibility with Laravel
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConstants.sellerProductsEndpoint}/$productId'));
    
    request.headers.addAll(_getHeaders());
    request.fields['_method'] = 'PATCH'; // Match the specified Laravel route method
    
    request.fields['name_en'] = nameEn;
    request.fields['name_bn'] = nameEn; 
    request.fields['slug'] = slug;
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['category_id'] = categoryId;
    request.fields['description_en'] = descriptionEn;
    request.fields['description_bn'] = descriptionEn;
    request.fields['addedby_id'] = userId;
    request.fields['seller_id'] = userId;
    
    request.fields['active'] = '1';

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('featured_image', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('Update Product Status: ${response.statusCode}');
    debugPrint('Update Product Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update product');
    }
  }
}
