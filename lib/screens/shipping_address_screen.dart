import 'package:flutter/material.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:hubli/providers/order_provider.dart';
import 'package:provider/provider.dart';

class ShippingAddressScreen extends StatefulWidget {
  const ShippingAddressScreen({super.key});

  @override
  State<ShippingAddressScreen> createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String _fullName = '';
  String _addressLine1 = '';
  String _addressLine2 = '';
  String _city = '';
  String _postalCode = '';
  String _country = '';

  void _saveAddress(CartProvider cart, OrderProvider orders) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      orders.addOrder(
        cart.items.values.toList(),
        cart.totalAmount,
        _fullName,
        _addressLine1,
        _addressLine2,
        _city,
        _postalCode,
        _country,
      );
      cart.clear();
      Navigator.of(context).pushReplacementNamed('/orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final orders = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipping Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _fullName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address Line 1'),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address Line 2 (Optional)'),
                onSaved: (value) {
                  _addressLine2 = value ?? '';
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'City'),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Postal Code'),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your country.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _country = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveAddress(cart, orders),
                child: const Text('Place Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}