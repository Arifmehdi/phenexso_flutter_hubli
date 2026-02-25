import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hubli/models/product.dart';
import 'package:hubli/services/seller_product_service.dart';

class SellerProductProvider with ChangeNotifier {
  SellerProductService _service;
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  SellerProductProvider(this._service);

  List<Product> get products => [..._products];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateService(SellerProductService newService) {
    _service = newService;
    // We don't fetch automatically here, but we could if we wanted to
  }

  Future<void> fetchSellerProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _service.fetchSellerProducts();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct({
    required String nameEn,
    required String slug,
    required double price,
    required int stock,
    required String categoryId,
    required String descriptionEn,
    required String userId,
    File? image,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.addProduct(
        nameEn: nameEn,
        slug: slug,
        price: price,
        stock: stock,
        categoryId: categoryId,
        descriptionEn: descriptionEn,
        userId: userId,
        image: image,
      );
      // After success, refresh the list
      await fetchSellerProducts();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
