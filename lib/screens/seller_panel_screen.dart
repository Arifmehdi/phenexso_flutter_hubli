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
  int _selectedIndex = 5; // Initialized to 5 (Account/Dashboard)
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
      _selectedIndex = 2; // Switch to Products tab
    });
  }

  void _onItemTapped(int index) {
    if (index == 0) {
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
      const SizedBox.shrink(),
      AddEditProductScreen(
        product: _editingProduct,
        onSuccess: () => _changeTab(2),
      ),
      SellerProductListScreen(onEdit: _startEditing),
      const OrderManagementScreen(),
      const SellerChatUsersScreen(),
      const SellerHomeScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_selectedIndex == 1 && _editingProduct != null 
            ? 'Edit Product' 
            : (_selectedIndex == 5 ? 'Seller Dashboard' : 'Seller Panel')),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: SellerDrawer(
        selectedIndex: _selectedIndex,
        onTabChange: _changeTab,
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
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

class SellerDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChange;

  const SellerDrawer({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.logoutEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authProvider.token}',
        },
      );

      if (response.statusCode == 200) {
        await authProvider.logout();
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Text(
                    authProvider.user?.name[0].toUpperCase() ?? 'S',
                    style: TextStyle(fontSize: 24, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  authProvider.user?.name ?? 'Seller',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  authProvider.user?.email ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: selectedIndex == 5 || selectedIndex == 0,
            onTap: () {
              Navigator.pop(context);
              onTabChange(5);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_box),
            title: const Text('Add Product'),
            selected: selectedIndex == 1,
            onTap: () {
              Navigator.pop(context);
              onTabChange(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('My Products'),
            selected: selectedIndex == 2,
            onTap: () {
              Navigator.pop(context);
              onTabChange(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Orders'),
            selected: selectedIndex == 3,
            onTap: () {
              Navigator.pop(context);
              onTabChange(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chat'),
            selected: selectedIndex == 4,
            onTap: () {
              Navigator.pop(context);
              onTabChange(4);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PasswordChangeScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('Contact Support'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactSupportScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}

class SellerHomeScreen extends StatefulWidget {
  final bool isEmbedded;
  const SellerHomeScreen({super.key, this.isEmbedded = false});

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
    final user = Provider.of<AuthProvider>(context).user;
    
    return Consumer<SellerDashboardProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.errorMessage != null) return Center(child: Text('Error: ${provider.errorMessage}'));
        if (provider.dashboardData == null) return const Center(child: Text('No data'));

        final data = provider.dashboardData!;
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEmbedded) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user?.name[0].toUpperCase() ?? 'S',
                        style: const TextStyle(fontSize: 30, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Seller Name',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? 'seller@example.com',
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Seller Account',
                              style: TextStyle(fontSize: 12, color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Dashboard Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: <Widget>[
                _buildMetricCard(context, 'Total Products', data.totalProducts.toString(), Icons.production_quantity_limits),
                _buildMetricCard(context, 'Sales Today', '৳${data.totalSalesToday.toStringAsFixed(2)}', Icons.attach_money),
                _buildMetricCard(context, 'Pending', data.totalOrdersPending.toString(), Icons.pending_actions),
                _buildMetricCard(context, 'Shipped', data.totalOrdersShipped.toString(), Icons.local_shipping),
              ],
            ),
          ],
        );

        if (widget.isEmbedded) {
          return content;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: content,
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
