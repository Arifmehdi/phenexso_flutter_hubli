class Product {
  final String id;
  final String name;
  final double price;
  final double purchasePrice; // New field for purchase_price
  final int stock; // New field for stock
  final List<String> imageUrls;
  final String category;
  final String? categoryId; // Added for editing
  final double rating;
  final String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.purchasePrice, // Added to constructor
    required this.stock, // Added to constructor
    required this.imageUrls,
    required this.category,
    this.categoryId,
    required this.rating,
    required this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String categoryName = 'Uncategorized';
    if (json['categories'] != null && (json['categories'] as List).isNotEmpty) {
      categoryName = json['categories'][0]['name'] ?? 'Uncategorized';
    }

    return Product(
      id: (json['id'] ?? '').toString(),
      name: json['name_en'] as String? ?? 'Unknown Product',
      price: (json['price'] is String)
          ? (double.tryParse(json['price']) ?? 0.0)
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchase_price'] is String)
          ? (double.tryParse(json['purchase_price']) ?? 0.0)
          : (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] is String)
          ? (int.tryParse(json['stock']) ?? 0)
          : (json['stock'] as num?)?.toInt() ?? 0,
      imageUrls: [
        (json['featured_image'] != null
            ? 'https://hublibd.com/uslive/pnism/${json['featured_image']}'
            : 'assets/images/placeholder.png'),
      ],
      category: categoryName,
      categoryId: (json['category_id'] ?? '').toString(),
      rating: (json['average_rating'] is String)
          ? (double.tryParse(json['average_rating']) ?? 0.0)
          : (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      description:
          json['description_en'] as String? ?? 'No description available.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': name,
      'price': purchasePrice,
      'stock': stock,
      'featured_image': imageUrls.isNotEmpty
          ? imageUrls[0].replaceAll('https://hublibd.com/uploads/product/', '')
          : null,
      'category': category,
      'average_rating': rating,
      'description_en': description,
    };
  }
}
