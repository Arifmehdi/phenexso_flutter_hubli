class Order {
  final String id;
  final String customerName;
  final DateTime orderDate;
  final double totalAmount;
  final String status;
  final List<String> itemIds; // To link with InventoryItem

  Order({
    required this.id,
    required this.customerName,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
    required this.itemIds,
  });
}
