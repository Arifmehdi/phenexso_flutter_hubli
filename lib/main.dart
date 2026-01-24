import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubli/utils/colors.dart';
import 'package:hubli/screens/dashboard_screen.dart';
import 'package:hubli/screens/inventory_screen.dart';
import 'package:hubli/screens/orders_screen.dart';
import 'package:hubli/screens/shipments_screen.dart';
import 'package:hubli/screens/suppliers_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hubli SCM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: appColorsPrimary),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    InventoryScreen(),
    OrdersScreen(),
    ShipmentsScreen(),
    SuppliersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hubli SCM', style: GoogleFonts.poppins()),
        backgroundColor: appColorsPrimary,
        foregroundColor: Colors.white,
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Shipments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Suppliers'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: appColorsPrimary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // Added to prevent shifting when items are selected
      ),
    );
  }
}
