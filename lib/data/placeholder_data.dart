import 'package:hubli/models/inventory_item.dart';
import 'package:hubli/models/order.dart';
import 'package:hubli/models/shipment.dart';
import 'package:hubli/models/supplier.dart';

// Placeholder Data
List<InventoryItem> dummyInventoryItems = [
  InventoryItem(
    id: 'I001',
    name: 'Fresh Hilsha Fish',
    sku: 'FSH-HIL-001',
    quantity: 120,
    price: 800.00,
    category: 'Fish',
    location: 'Cold Storage A',
  ),
  InventoryItem(
    id: 'I002',
    name: 'Mutton (1kg)',
    sku: 'MET-MTN-002',
    quantity: 80,
    price: 1100.00,
    category: 'Meat',
    location: 'Freezer 3',
  ),
  InventoryItem(
    id: 'I003',
    name: 'Organic Spinach',
    sku: 'VEG-SPN-003',
    quantity: 300,
    price: 50.00,
    category: 'Vegetables',
    location: 'Warehouse B, Shelf 1',
  ),
  InventoryItem(
    id: 'I004',
    name: 'Red Lentils (Masur Dal)',
    sku: 'DAL-RED-004',
    quantity: 500,
    price: 140.00,
    category: 'Groceries',
    location: 'Dry Storage, Section 2',
  ),
  InventoryItem(
    id: 'I005',
    name: 'Cauliflower',
    sku: 'VEG-CAU-005',
    quantity: 250,
    price: 60.00,
    category: 'Vegetables',
    location: 'Warehouse B, Shelf 2',
  ),
];

List<Order> dummyOrders = [
  Order(
    id: 'ORD001',
    customerName: 'Global Tech Solutions',
    orderDate: DateTime(2025, 1, 20),
    totalAmount: 18000.00,
    status: 'Pending',
    itemIds: ['I001', 'I002'],
  ),
  Order(
    id: 'ORD002',
    customerName: 'Innovate Systems Ltd.',
    orderDate: DateTime(2025, 1, 18),
    totalAmount: 7500.00,
    status: 'Completed',
    itemIds: ['I003'],
  ),
  Order(
    id: 'ORD003',
    customerName: 'Future Logistics Co.',
    orderDate: DateTime(2025, 1, 22),
    totalAmount: 1350.00,
    status: 'Processing',
    itemIds: ['I004', 'I005'],
  ),
];

List<Shipment> dummyShipments = [
  Shipment(
    id: 'SHP001',
    trackingNumber: 'TRK789012345',
    carrier: 'FedEx',
    shipmentDate: DateTime(2025, 1, 21),
    status: 'In Transit',
    origin: 'New York, USA',
    destination: 'London, UK',
    orderIds: ['ORD001'],
  ),
  Shipment(
    id: 'SHP002',
    trackingNumber: 'TRK567890123',
    carrier: 'DHL',
    shipmentDate: DateTime(2025, 1, 19),
    deliveryDate: DateTime(2025, 1, 24),
    status: 'Delivered',
    origin: 'Shenzhen, China',
    destination: 'Sydney, Australia',
    orderIds: ['ORD002'],
  ),
  Shipment(
    id: 'SHP003',
    trackingNumber: 'TRK123456789',
    carrier: 'UPS',
    shipmentDate: DateTime(2025, 1, 23),
    status: 'Manifested',
    origin: 'Berlin, Germany',
    destination: 'Paris, France',
    orderIds: ['ORD003'],
  ),
];

List<Supplier> dummySuppliers = [
  Supplier(
    id: 'SUP001',
    name: 'কৃষি পণ্য সরবরাহ',
    contactPerson: 'মোহাম্মদ আলী',
    email: 'mohammad.ali@example.com',
    phone: '+8801712345678',
    address: '১০১, ফার্মগেট, ঢাকা, বাংলাদেশ',
  ),
  Supplier(
    id: 'SUP002',
    name: 'মৎস্য সরবরাহ কেন্দ্র',
    contactPerson: 'ফাতেমা বেগম',
    email: 'fatema.begum@example.com',
    phone: '+8801823456789',
    address: '২০২, সদরঘাট, চট্টগ্রাম, বাংলাদেশ',
  ),
  Supplier(
    id: 'SUP003',
    name: 'তাজা সবজি ভান্ডার',
    contactPerson: 'আব্দুর রহমান',
    email: 'abdur.rahman@example.com',
    phone: '+8801934567890',
    address: '৩০৩, নিউ মার্কেট, খুলনা, বাংলাদেশ',
  ),
];
