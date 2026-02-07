class Product {
  final String id;
  final String name;
  final double price;
  final List<String> imageUrls; // Changed to List<String>
  final String category;
  final double rating;
  final String description; // New field for product description

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls,
    required this.category,
    required this.rating,
    required this.description, // Initialize new field
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? '').toString(),
      name: json['name_en'] as String? ?? 'Unknown Product',
      price: (json['price'] is String)
          ? (double.tryParse(json['price']) ?? 0.0)
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrls: [(json['featured_image'] != null ? 'https://hublibd.com/uslive/pnism/${json['featured_image']}' : 'assets/images/placeholder.png')],
      category: json['category'] as String? ?? 'Uncategorized',
      rating: (json['average_rating'] is String)
          ? (double.tryParse(json['average_rating']) ?? 0.0)
          : (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description_en'] as String? ?? 'No description available.', // Map description_en
    );
  }
}