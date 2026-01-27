import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const CustomAppBar({
    super.key,
    required this.searchController,
    required this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2); // Two rows

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        color: Colors.white, // Changed to white background
        child: SafeArea(
          child: Column(
            children: [
              // First row: Logo, Globe, Notification
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Image.asset(
                      'assets/images/hubli_logo.png', // Assuming hubli_logo.png is in assets/images
                      height: 30.0, // Adjust height as needed
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.public, color: Colors.black), // Changed icon color to black
                    onPressed: () {
                      // Handle globe press
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.black), // Changed icon color to black
                    onPressed: () {
                      // Handle notification press
                    },
                  ),
                ],
              ),
              // Second row: Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFF008739)), // Border color added
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: const TextStyle(height: 1.0),
                      isDense: true, // Reduce overall height
                      contentPadding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 8.0), // Adjust padding
                      border: InputBorder.none,
                      suffixIcon: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF008739),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: onSearch,
                          iconSize: 20.0, // Reduce icon size to match dense padding
                          padding: EdgeInsets.zero, // Remove default IconButton padding
                          constraints: const BoxConstraints(), // Remove default IconButton constraints
                        ),
                      ),
                      prefixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF008739)),
                              onPressed: () {
                                searchController.clear();
                                onSearch();
                              },
                              iconSize: 20.0, // Reduce icon size
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      onSearch();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
