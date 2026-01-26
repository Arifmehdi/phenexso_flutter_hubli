import 'package:flutter/material.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:hubli/widgets/custom_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported, size: 20),
        ),
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported, size: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        searchController: TextEditingController(), // Dummy controller
        onSearch: () {}, // Dummy callback
        titleText: 'My Cart',
      ),
      body: cart.itemCount == 0
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 22, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.itemCount + 1, // Add 1 for the total/order card
                    itemBuilder: (ctx, i) {
                      if (i == cart.itemCount) {
                        return Card(
                          margin: const EdgeInsets.all(15),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Text(
                                  'Total',
                                  style: TextStyle(fontSize: 20),
                                ),
                                const Spacer(),
                                Chip(
                                  label: Text(
                                    NumberFormat.currency(locale: 'en_BD', symbol: 'BDT ').format(cart.totalAmount),
                                    style: TextStyle(
                                      color: Theme.of(context).primaryTextTheme.titleLarge?.color,
                                    ),
                                  ),
                                  backgroundColor: Theme.of(context).primaryColor,
                                ),
                                TextButton(
                                  child: const Text('ORDER NOW'),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed('/order-confirmation');
                                  },
                                )
                              ],
                            ),
                          ),
                        );
                      }
                      final cartItem = cart.items.values.toList()[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/product-detail',
                            arguments: cartItem.product,
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: _buildProductImage(cartItem.product.imageUrl),
                                ),
                              ),
                                                          title: Text(cartItem.product.name),
                                                          subtitle: Text(
                                                              'Price: \$${cartItem.product.price.toStringAsFixed(2)}'),
                                                          trailing: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              IconButton(
                                                                icon: const Icon(Icons.remove),
                                                                onPressed: () {
                                                                  Provider.of<CartProvider>(context,
                                                                          listen: false)
                                                                      .decreaseQuantity(cartItem.product.id);
                                                                },
                                                              ),
                                                              Text('${cartItem.quantity}'),
                                                              IconButton(
                                                                icon: const Icon(Icons.add),
                                                                onPressed: () {
                                                                  Provider.of<CartProvider>(context,
                                                                          listen: false)
                                                                      .increaseQuantity(cartItem.product.id);
                                                                },
                                                              ),
                                                            ],
                                                          ),                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}