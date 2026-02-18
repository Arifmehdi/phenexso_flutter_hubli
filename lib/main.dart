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
import 'package:hubli/screens/buyer_panel_screen.dart'; // New Import
import 'package:hubli/screens/forgot_password_screen.dart'; // Add missing import
import 'package:hubli/screens/main_navigation_screen.dart';

import 'package:hubli/providers/category_provider.dart';
import 'package:hubli/screens/all_categories_screen.dart';
import 'package:hubli/screens/category_products_screen.dart';
import 'package:hubli/providers/wishlist_provider.dart';
import 'package:hubli/screens/wishlist_screen.dart'; // Add this import
import 'package:hubli/screens/cost_calculator_screen.dart'; // Add this import
import 'package:hubli/screens/order_tracking_screen.dart'; // Add this import // Add this import
import 'package:hubli/services/rider_dashboard_service.dart'; // New Import for RiderDashboardService
import 'package:hubli/providers/rider_dashboard_provider.dart'; // New Import for RiderDashboardProvider
import 'package:hubli/services/seller_dashboard_service.dart'; // New Import for SellerDashboardService
import 'package:hubli/providers/seller_dashboard_provider.dart'; // New Import for SellerDashboardProvider

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
        ChangeNotifierProxyProvider<AuthProvider, RiderDashboardProvider>(
          create: (context) => RiderDashboardProvider(RiderDashboardService(null)), // Initial with null token
          update: (context, auth, riderDashboardProvider) {
            debugPrint('RiderDashboardProvider update with token: ${auth.token}');
            return RiderDashboardProvider(RiderDashboardService(auth.token));
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SellerDashboardProvider>(
          create: (context) => SellerDashboardProvider(SellerDashboardService(null)), // Initial with null token
          update: (context, auth, sellerDashboardProvider) {
            debugPrint('SellerDashboardProvider update with token: ${auth.token}');
            return SellerDashboardProvider(SellerDashboardService(auth.token));
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
      initialRoute: MainNavigationScreen.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case MainNavigationScreen.routeName:
            return MaterialPageRoute(builder: (context) => const MainNavigationScreen());
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
            return MaterialPageRoute(builder: (context) => SellerPanelScreen());
          case '/rider-panel':
            return MaterialPageRoute(builder: (context) => RiderPanelScreen());
          case '/buyer-panel': // New Buyer Panel route
            return MaterialPageRoute(builder: (context) => const BuyerPanelScreen());
          case '/forgot-password': // New Forgot Password route
            return MaterialPageRoute(builder: (context) => const ForgotPasswordScreen());
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