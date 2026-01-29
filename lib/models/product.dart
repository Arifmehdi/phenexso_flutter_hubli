class Product {
  final String id;
  final String name;
  final double price;
  final List<String> imageUrls; // Changed to List<String>
  final String category;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrls, // Updated to imageUrls
    required this.category,
    required this.rating,
  });
}