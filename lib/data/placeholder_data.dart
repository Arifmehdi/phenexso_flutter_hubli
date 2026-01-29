import 'package:hubli/models/product.dart';

// Placeholder Product Data for an E-commerce App
List<Product> dummyProducts = [
  Product(
    id: 'P001',
    name: 'Fresh Hilsha Fish',
    price: 800.00,
    imageUrls: [ // Changed to imageUrls (List)
      'assets/images/product/hilsa.jpg',
      'assets/images/product/hilsa.jpg', // Duplicated for demonstration
    ],
    category: 'Fish',
    rating: 4.5,
  ),
  Product(
    id: 'P002',
    name: 'Mutton (1kg)',
    price: 1100.00,
    imageUrls: [ // Changed to imageUrls (List)
      'assets/images/product/mutton.jpg',
      'assets/images/product/mutton.jpg', // Duplicated for demonstration
    ],
    category: 'Meat',
    rating: 4.2,
  ),
  Product(
    id: 'P003',
    name: 'Organic Spinach',
    price: 50.00,
    imageUrls: [ // Changed to imageUrls (List)
      'assets/images/product/spinach.jpg',
      'assets/images/product/spinach.jpg', // Duplicated for demonstration
    ],
    category: 'Vegetables',
    rating: 4.7,
  ),
  Product(
    id: 'P004',
    name: 'Red Lentils (Masur Dal)',
    price: 140.00,
    imageUrls: [ // Changed to imageUrls (List)
      'assets/images/product/lentil.jpg',
      'assets/images/product/lentil.jpg', // Duplicated for demonstration
    ],
    category: 'Groceries',
    rating: 4.0,
  ),
  Product(
    id: 'P005',
    name: 'Cauliflower',
    price: 60.00,
    imageUrls: [ // Changed to imageUrls (List)
      'assets/images/product/cauliflower.jpg',
      'assets/images/product/cauliflower.jpg', // Duplicated for demonstration
    ],
    category: 'Vegetables',
    rating: 4.6,
  ),
  Product(
    id: 'P006',
    name: 'Apple (1kg)',
    price: 200.00,
    imageUrls: [ // Changed to imageUrls (List)
      'assets/images/product/apple.jpg',
      'assets/images/product/apple.jpg', // Duplicated for demonstration
    ],
    category: 'Fruit',
    rating: 4.8,
  ),
  Product(
    id: 'P007',
    name: 'Banana (1 dozen)',
    price: 80.00,
    imageUrls: [ // Changed to imageUrls (List)
      'assets/images/product/banana.jpg',
      'assets/images/product/banana.jpg', // Duplicated for demonstration
    ],
    category: 'Fruit',
    rating: 4.3,
  ),
  Product(
    id: 'P008',
    name: 'Chicken Breast (500g)',
    price: 350.00,
    imageUrls: [ // Changed to imageUrls (List)
      'assets/images/product/chicken.jpg',
      'assets/images/product/chicken.jpg', // Duplicated for demonstration
    ],
    category: 'Meat',
    rating: 4.9,
  ),
];
