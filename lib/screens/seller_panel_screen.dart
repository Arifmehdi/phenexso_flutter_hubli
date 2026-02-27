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
import 'package:hubli/providers/order_provider.dart';
import 'package:hubli/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SellerPanelScreen extends StatefulWidget {
  const SellerPanelScreen({super.key});

  @override
  State<SellerPanelScreen> createState() => _SellerPanelScreenState();
}

class _SellerPanelScreenState extends State<SellerPanelScreen> {
  int _selectedIndex = 0;
  Product? _editingProduct;

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 1) _editingProduct = null; // Clear edit state if not on Add/Edit tab
    });
  }

  void _startEditing(Product product) {
    setState(() {
      _editingProduct = product;
      _selectedIndex = 1; // Switch to Add/Edit tab
    });
  }

  void _onItemTapped(int index) {
    if (index == 0 && _selectedIndex == 0) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      setState(() {
        _selectedIndex = index;
        if (index != 1) _editingProduct = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      const SellerHomeScreen(),
      AddEditProductScreen(
        product: _editingProduct,
        onSuccess: () => _changeTab(2),
      ),
      SellerProductListScreen(onEdit: _startEditing),
      const OrderManagementScreen(),
      const SellerChatUsersScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 1 && _editingProduct != null ? 'Edit Product' : 'Seller Panel'),
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

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  final VoidCallback onSuccess;
  const AddEditProductScreen({super.key, this.product, required this.onSuccess});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _slugController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descEnController = TextEditingController();
  String? _selectedCategoryId;
  File? _image;

  @override
  void initState() {
    super.initState();
    _nameEnController.addListener(_onNameChanged);
    _initFields();
    Future.microtask(() => Provider.of<CategoryProvider>(context, listen: false).fetchCategories());
  }

  void _initFields() {
    if (widget.product != null) {
      _nameEnController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stock.toString();
      _descEnController.text = widget.product!.description;
      // Slug logic: if the product has a slug from API, we'd use it, otherwise generate
      _onNameChanged();
    } else {
      _nameEnController.clear();
      _priceController.clear();
      _stockController.clear();
      _descEnController.clear();
      _slugController.clear();
      _selectedCategoryId = null;
      _image = null;
    }
  }

  @override
  void didUpdateWidget(AddEditProductScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product) {
      _initFields();
    }
  }

  @override
  void dispose() {
    _nameEnController.removeListener(_onNameChanged);
    _nameEnController.dispose();
    _slugController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descEnController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    String name = _nameEnController.text;
    String slug = name.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
    _slugController.text = slug;
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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.id.toString() ?? '0';

        if (widget.product == null) {
          await provider.addProduct(
            nameEn: _nameEnController.text,
            slug: _slugController.text,
            price: double.parse(_priceController.text),
            stock: int.parse(_stockController.text),
            categoryId: _selectedCategoryId!,
            descriptionEn: _descEnController.text,
            userId: userId,
            image: _image,
          );
        } else {
          await provider.updateProduct(
            productId: widget.product!.id,
            nameEn: _nameEnController.text,
            slug: _slugController.text,
            price: double.parse(_priceController.text),
            stock: int.parse(_stockController.text),
            categoryId: _selectedCategoryId!,
            descriptionEn: _descEnController.text,
            userId: userId,
            image: _image,
          );
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.product == null ? 'Product added successfully!' : 'Product updated successfully!'))
        );
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
                Text(widget.product == null ? 'Add New Product' : 'Edit Product', 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextFormField(controller: _nameEnController, decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _slugController, 
                  decoration: const InputDecoration(labelText: 'Product Slug (URL)', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
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
                  value: _selectedCategoryId,
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
                      ? (widget.product != null && widget.product!.imageUrls.isNotEmpty && !widget.product!.imageUrls[0].contains('placeholder')
                          ? Image.network(widget.product!.imageUrls[0], fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey)))
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
                    child: Text(widget.product == null ? 'SUBMIT PRODUCT' : 'UPDATE PRODUCT'),
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
  final Function(Product) onEdit;
  const SellerProductListScreen({super.key, required this.onEdit});

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
                leading: product.imageUrls.isNotEmpty && !product.imageUrls[0].contains('placeholder')
                  ? Image.network(product.imageUrls[0], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image))
                  : const Icon(Icons.image),
                title: Text(product.name),
                subtitle: Text('Price: ৳${product.price.toStringAsFixed(2)} | Stock: ${product.stock}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => widget.onEdit(product),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrderProvider>(context, listen: false).fetchAndSetSellerOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => orderProvider.fetchAndSetSellerOrders(),
          child: orderProvider.sellerOrders.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No orders found for your products.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: orderProvider.sellerOrders.length,
                  itemBuilder: (context, index) {
                    final order = orderProvider.sellerOrders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: ExpansionTile(
                        title: Text(
                          'Order #${order.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate)),
                            Text(
                              'Status: ${order.paymentStatus.toUpperCase()}',
                              style: TextStyle(
                                color: order.paymentStatus == 'paid' ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '৳${order.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text('${item.productName} x ${item.quantity}')),
                                      Text('৳${item.totalCost.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                )).toList(),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text('৳${order.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const Text('Shipping Address:', style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(order.addressTitle),
                                Text('Customer: ${order.name}'),
                                Text('Mobile: ${order.mobile}'),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
