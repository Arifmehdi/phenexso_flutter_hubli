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
    // Assuming the backend filters by seller_id automatically when authenticated
    final response = await http.get(
      Uri.parse(ApiConstants.productsEndpoint),
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
    required double price,
    required int stock,
    required String categoryId,
    required String descriptionEn,
    File? image,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(ApiConstants.productsEndpoint));
    
    request.headers.addAll(_getHeaders());
    
    request.fields['name_en'] = nameEn;
    request.fields['name_bn'] = nameEn; // Fallback to English
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['category_id'] = categoryId;
    request.fields['description_en'] = descriptionEn;
    request.fields['description_bn'] = descriptionEn; // Fallback to English
    
    // Add other default fields if needed by Laravel (e.g., active, feature)
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
}
