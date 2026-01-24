import 'package:flutter/material.dart';

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
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ],
    );
  }
}
