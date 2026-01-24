class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final int quantity;
  final double price;
  final String category;
  final String location;

  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.price,
    required this.category,
    required this.location,
  });
}
