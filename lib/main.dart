import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubli/utils/colors.dart';
import 'package:hubli/screens/product_list_screen.dart';
import 'package:hubli/screens/product_detail_screen.dart';
import 'package:hubli/screens/cart_screen.dart';
import 'package:hubli/models/product.dart'; // Import Product model for ProductDetailScreen arguments

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hubli E-commerce', // Changed title
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appColorsPrimary),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: appColorsPrimary,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ProductListScreen(),
        '/product-detail': (context) {
          final product = ModalRoute.of(context)!.settings.arguments as Product;
          return ProductDetailScreen(product: product);
        },
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}