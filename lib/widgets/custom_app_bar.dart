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
        decoration: BoxDecoration(
          color: Colors.white, // Changed to white background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // First row: Logo, Globe, Notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0), // Changed from 12.0 to 16.0
                    child: SizedBox(
                      height: 32.0, // A bit larger for the logo
                      child: Image.asset(
                        'assets/images/hubli_logo.png',
                        fit: BoxFit.contain, // Ensure logo fits within the SizedBox
                      ),
                    ),
                  ),
                  Padding( // Added Padding around the icon group
                    padding: const EdgeInsets.only(right: 16.0), // 16.0 right padding
                    child: Row( // Group icons together
                      children: [
                        IconButton(
                          icon: const Icon(Icons.public, color: Colors.black),
                          onPressed: () {
                            // Handle globe press
                          },
                          iconSize: 28.0, // Consistent icon size
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications, color: Colors.black),
                          onPressed: () {
                            // Handle notification press
                          },
                          iconSize: 28.0, // Consistent icon size
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Second row: Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0), // Changed from 10.0 to 16.0
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
