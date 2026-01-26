import 'package:flutter/material.dart';
import 'package:hubli/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final String titleText; // Optional title for pages without search

  const CustomAppBar({
    Key? key,
    required this.searchController,
    required this.onSearch,
    this.titleText = '',
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleText.isNotEmpty
          ? Text(titleText)
          : Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    'assets/images/hubli_logo.png', // Assuming hubli_logo.png is in assets/images
                    height: 30.0, // Adjust height as needed
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: onSearch,
                      ),
                    ),
                    onChanged: (value) {
                      onSearch();
                    },
                  ),
                ),
              ],
            ),
      actions: [
        Consumer<CartProvider>(
          builder: (_, cart, ch) => badges.Badge(
            badgeContent: Text(
              cart.itemCount.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            showBadge: cart.itemCount > 0,
            child: ch,
          ),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.list_alt),
          onPressed: () {
            debugPrint('Navigating to /orders');
            Navigator.of(context).pushNamed('/orders');
          },
        ),
      ],
    );
  }
}
