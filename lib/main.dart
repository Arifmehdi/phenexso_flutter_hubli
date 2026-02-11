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
import 'package:hubli/providers/product_provider.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:hubli/services/chat_service.dart'; // New Import
import 'package:hubli/providers/chat_provider.dart'; // New Import
import 'package:hubli/services/user_service.dart'; // New Import
import 'package:hubli/providers/user_provider.dart'; // New Import
import 'package:hubli/services/admin_user_service.dart'; // New Import
import 'package:hubli/providers/admin_user_provider.dart'; // New Import

import 'package:hubli/screens/order_confirmation_screen.dart';
import 'package:hubli/screens/order_history_screen.dart';

import 'package:hubli/screens/shipping_address_screen.dart';
import 'package:hubli/screens/login_screen.dart';
import 'package:hubli/screens/registration_screen.dart';
import 'package:hubli/screens/account_screen.dart';
import 'package:hubli/screens/admin_panel_screen.dart';
import 'package:hubli/screens/seller_panel_screen.dart';
import 'package:hubli/screens/rider_panel_screen.dart';
import 'package:hubli/providers/category_provider.dart';
import 'package:hubli/screens/all_categories_screen.dart';
import 'package:hubli/screens/category_products_screen.dart';
import 'package:hubli/providers/wishlist_provider.dart';
import 'package:hubli/screens/wishlist_screen.dart'; // Add this import
import 'package:hubli/screens/cost_calculator_screen.dart'; // Add this import
import 'package:hubli/screens/order_tracking_screen.dart'; // Add this import // Add this import

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ChatProvider>(
          create: (context) => ChatProvider(ChatService(''), Provider.of<AuthProvider>(context, listen: false)),
          update: (context, auth, chat) {
            debugPrint('ChatProvider update with token: ${auth.token}');
            return ChatProvider(ChatService(auth.token ?? ''), auth);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (context) => UserProvider(UserService('')), // Initial UserService with empty token
          update: (context, auth, userProvider) {
            debugPrint('UserProvider update with token: ${auth.token}');
            return UserProvider(UserService(auth.token ?? ''));
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminUserProvider>(
          create: (context) => AdminUserProvider(AdminUserService('')), // Initial AdminUserService with empty token
          update: (context, auth, adminUserProvider) {
            debugPrint('AdminUserProvider update with token: ${auth.token}');
            return AdminUserProvider(AdminUserService(auth.token ?? ''));
          },
        ),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => OrderProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()), // Add WishlistProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MaterialApp(
      title: 'Hubli E-commerce', // Changed title
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appColorsPrimary),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: appColorsPrimary, // Use primary color for ElevatedButtons
            foregroundColor: Colors.white, // Text color for ElevatedButtons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Consistent border radius
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: appColorsPrimary, // Text color for TextButtons
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: appColorsPrimary, // Text color for OutlinedButtons
            side: const BorderSide(color: appColorsPrimary), // Border color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Consistent border radius
            ),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            // This is the default home route, so no initial category filter
            return MaterialPageRoute(builder: (context) => const ProductListScreen());
          case '/category-products':
            final args = settings.arguments as Map<String, String>;
            return MaterialPageRoute(
                builder: (context) => CategoryProductsScreen(
                      categorySlug: args['slug']!,
                      categoryName: args['name']!,
                    ));
          case '/product-detail':
            final product = settings.arguments as Product;
            return MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product));
          case '/cart':
            return MaterialPageRoute(builder: (context) => const CartScreen());
          case '/order-confirmation':
            return MaterialPageRoute(builder: (context) => const OrderConfirmationScreen());
          case '/shipping-address':
            return MaterialPageRoute(builder: (context) => const ShippingAddressScreen());
          case '/orders':
            return MaterialPageRoute(builder: (context) => const OrderHistoryScreen());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegistrationScreen());
          case '/account':
            return MaterialPageRoute(builder: (context) => const AccountScreen());
          case '/admin-panel':
            return MaterialPageRoute(builder: (context) => const AdminPanelScreen());
          case '/seller-panel':
            return MaterialPageRoute(builder: (context) => const SellerPanelScreen());
          case '/rider-panel':
            return MaterialPageRoute(builder: (context) => const RiderPanelScreen());
          case '/all-categories':
            return MaterialPageRoute(builder: (context) => const AllCategoriesScreen());
          case '/wishlist': // Add WishlistScreen route
            return MaterialPageRoute(builder: (context) => const WishlistScreen());
          case '/cost-calculator': // Add CostCalculatorScreen route
            return MaterialPageRoute(builder: (context) => const CostCalculatorScreen());
          case '/order-tracking': // Add OrderTrackingScreen route
            return MaterialPageRoute(builder: (context) => const OrderTrackingScreen());
          default:
            return MaterialPageRoute(builder: (context) => Text('Error: Unknown route ${settings.name}'));
        }
      },
    ); // End of MaterialApp
      }, // End of Builder's builder function
    ); // End of Builder widget
  }
}