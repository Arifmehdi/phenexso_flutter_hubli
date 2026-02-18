import 'package:flutter/material.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:hubli/providers/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:hubli/models/user_role.dart'; // Import UserRole enum

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String _receiverName = '';
  String _receiverPhoneNumber = ''; // New field
  String _addressLine1 = '';
  String _city = '';
  String _postalCode = '';
  double _contentWeight = 1.0; // New field for slider

  int _selectedIndex = 3; // Index for Shipping

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return; // Do nothing if the current tab is re-selected
    }
    setState(() {
      _selectedIndex = index;
    });

    if (!mounted) return; // Add mounted check here

    // Handle navigation based on index
    switch (index) {
      case 0:
        // Navigate to home only if not already on home
        if (ModalRoute.of(context)?.settings.name != '/') {
          Navigator.of(context).pushReplacementNamed('/');
        }
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('RFQ Screen (Not Implemented)')),
        );
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/cart'); // Cart
        break;
      case 3:
        // Already on Shipping screen
        break;
      case 4:
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!mounted) return; // Re-check mounted after potentially long Provider operation
        if (authProvider.isAuthenticated) {
          if (authProvider.user!.role == UserRole.admin) {
            Navigator.of(context).pushReplacementNamed('/admin-panel'); // Navigate to Admin Panel
          } else {
            Navigator.of(context).pushReplacementNamed('/account'); // Navigate to Account for other roles
          }
        } else {
          Navigator.of(context).pushReplacementNamed('/login'); // Navigate to Login
        }
        break;
    }
  }
  void _saveAddress(CartProvider cart, OrderProvider orders) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      orders.addOrder(
        cart.items.values.toList(),
        cart.totalAmount,
        _receiverName, // Using receiver name
        _addressLine1,
        _city,
        _postalCode,
        '', // Pass empty string for addressLine2
        '', // Pass empty string for country
      );
      cart.clear();
      if (!mounted) return; // Add mounted check here
      Navigator.of(context).pushReplacementNamed('/orders');
    }
  }
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final orders = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Ensure title and other icons are visible
        elevation: 1, // Add a subtle shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
        title: const Text('Shipping Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Receiver Details
              const Text(
                'Receiver Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Receiver Name',
                  border: OutlineInputBorder(), // Added border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter receiver\'s name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _receiverName = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Receiver Phone Number',
                  border: OutlineInputBorder(), // Added border
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter receiver\'s phone number.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _receiverPhoneNumber = value!;
                },
              ),
              const SizedBox(height: 20),
              // Delivery Address
              const Text(
                'Delivery Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Enter Full Address',
                  border: OutlineInputBorder(), // Added border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _addressLine1 = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(), // Added border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _city = value!;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  border: OutlineInputBorder(), // Added border
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your postal code.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _postalCode = value!;
                },
              ),
              const SizedBox(height: 20),
              // Content Weight Slider
              Text(
                'Content Weight: ${_contentWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _contentWeight,
                min: 0.1,
                max: 100.0,
                divisions: 1000,
                label: _contentWeight.toStringAsFixed(1),
                onChanged: (double value) {
                  setState(() {
                    _contentWeight = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveAddress(cart, orders),
                child: const Text('Confirm'), // Changed button text
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment), // RFQ
            label: 'RFQ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping), // Shipping
            label: 'Shipping',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Account
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
      ),
    );
  }
}
