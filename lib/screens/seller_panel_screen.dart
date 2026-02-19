import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:hubli/providers/auth_provider.dart';
import 'package:hubli/utils/api_constants.dart';
import 'package:hubli/screens/seller_chat_users_screen.dart';
import 'dart:convert';
import 'package:hubli/screens/profile_edit_screen.dart';
import 'package:hubli/screens/password_change_screen.dart';
import 'package:hubli/screens/contact_support_screen.dart';
import 'package:hubli/providers/seller_dashboard_provider.dart';
import 'package:hubli/providers/seller_product_provider.dart';
import 'package:hubli/providers/category_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SellerPanelScreen extends StatefulWidget {
  const SellerPanelScreen({super.key});

  @override
  State<SellerPanelScreen> createState() => _SellerPanelScreenState();
}

class _SellerPanelScreenState extends State<SellerPanelScreen> {
  int _selectedIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    if (index == 0 && _selectedIndex == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We define _widgetOptions inside build to capture 'this' or pass callbacks
    final List<Widget> widgetOptions = <Widget>[
      const SellerHomeScreen(),
      AddNewProductScreen(onSuccess: () => _changeTab(2)), // Switch to list on success
      const SellerProductListScreen(),
      const OrderManagementScreen(),
      const SellerChatUsersScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SellerDashboardProvider>(context, listen: false).fetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.errorMessage != null) return Center(child: Text('Error: ${provider.errorMessage}'));
        if (provider.dashboardData == null) return const Center(child: Text('No data'));

        final data = provider.dashboardData!;
        return GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildMetricCard(context, 'Total Products', data.totalProducts.toString(), Icons.production_quantity_limits),
            _buildMetricCard(context, 'Sales Today', '৳${data.totalSalesToday.toStringAsFixed(2)}', Icons.attach_money),
            _buildMetricCard(context, 'Pending', data.totalOrdersPending.toString(), Icons.pending_actions),
            _buildMetricCard(context, 'Shipped', data.totalOrdersShipped.toString(), Icons.local_shipping),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: Theme.of(context).primaryColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddNewProductScreen extends StatefulWidget {
  final VoidCallback onSuccess;
  const AddNewProductScreen({super.key, required this.onSuccess});

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descEnController = TextEditingController();
  String? _selectedCategoryId;
  File? _image;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<CategoryProvider>(context, listen: false).fetchCategories());
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submit(SellerProductProvider provider) async {
    if (_formKey.currentState!.validate() && _selectedCategoryId != null) {
      try {
        await provider.addProduct(
          nameEn: _nameEnController.text,
          price: double.parse(_priceController.text),
          stock: int.parse(_stockController.text),
          categoryId: _selectedCategoryId!,
          descriptionEn: _descEnController.text,
          image: _image,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product added successfully!')));
        widget.onSuccess();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryProvider>(context).categories;

    return Consumer<SellerProductProvider>(
      builder: (context, sellerProductProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text('Add New Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextFormField(controller: _nameEnController, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
                    const SizedBox(width: 10),
                    Expanded(child: TextFormField(controller: _stockController, decoration: const InputDecoration(labelText: 'Stock', border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Required' : null)),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  items: categories.map((c) => DropdownMenuItem(value: c.id.toString(), child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                ),
                const SizedBox(height: 10),
                TextFormField(controller: _descEnController, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()), maxLines: 3),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                    child: _image == null 
                      ? const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey))
                      : Image.file(_image!, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                if (sellerProductProvider.isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () => _submit(sellerProductProvider),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('SUBMIT PRODUCT'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SellerProductListScreen extends StatefulWidget {
  const SellerProductListScreen({super.key});

  @override
  State<SellerProductListScreen> createState() => _SellerProductListScreenState();
}

class _SellerProductListScreenState extends State<SellerProductListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<SellerProductProvider>(context, listen: false).fetchSellerProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.errorMessage != null) return Center(child: Text('Error: ${provider.errorMessage}'));
        if (provider.products.isEmpty) return const Center(child: Text('No products found. Add one!'));

        return ListView.builder(
          itemCount: provider.products.length,
          itemBuilder: (context, index) {
            final product = provider.products[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: ListTile(
                leading: product.imageUrls.isNotEmpty 
                  ? Image.network(product.imageUrls[0], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                  : const Icon(Icons.image),
                title: Text(product.name),
                subtitle: Text('Price: ৳${product.price.toStringAsFixed(2)} | Stock: ${product.stock}'),
                trailing: const Icon(Icons.edit),
              ),
            );
          },
        );
      },
    );
  }
}

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Manage Orders', style: TextStyle(fontSize: 24)));
  }
}

class MoreSellerOptionsScreen extends StatelessWidget {
  const MoreSellerOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('More Seller Options', style: TextStyle(fontSize: 24)));
  }
}
