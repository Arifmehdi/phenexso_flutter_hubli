import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubli/utils/colors.dart';
import 'package:hubli/screens/product_list_screen.dart';
import 'package:hubli/screens/product_detail_screen.dart';
import 'package:hubli/screens/cart_screen.dart';
import 'package:hubli/models/product.dart'; // Import Product model for ProductDetailScreen arguments
import 'package:provider/provider.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:hubli/providers/order_provider.dart';
import 'package:hubli/providers/auth_provider.dart';

import 'package:hubli/screens/order_confirmation_screen.dart';
import 'package:hubli/screens/order_history_screen.dart';

import 'package:hubli/screens/shipping_address_screen.dart';
import 'package:hubli/screens/login_screen.dart';
import 'package:hubli/screens/registration_screen.dart';
import 'package:hubli/screens/account_screen.dart';
import 'package:hubli/screens/admin_panel_screen.dart';
import 'package:hubli/screens/seller_panel_screen.dart';
import 'package:hubli/screens/rider_panel_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/order-confirmation': (context) => const OrderConfirmationScreen(),
        '/shipping-address': (context) => const ShippingAddressScreen(),
        '/orders': (context) => const OrderHistoryScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/account': (context) => const AccountScreen(),
        '/admin-panel': (context) => const AdminPanelScreen(),
        '/seller-panel': (context) => const SellerPanelScreen(),
        '/rider-panel': (context) => const RiderPanelScreen(),
      },
    );
  }
}