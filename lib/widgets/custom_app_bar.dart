import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final String? title;
  final bool showBackButton; // New parameter
  final VoidCallback? onBackButtonPressed; // New parameter

  const CustomAppBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    this.title,
    this.showBackButton = false, // Default to false
    this.onBackButtonPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // First row: Back button (optional), Title/Logo, Globe, Notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row( // Group back button and title/logo together
                    children: [
                      if (showBackButton) // Conditionally display back button
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: onBackButtonPressed ?? () => Navigator.of(context).pop(),
                        )
                      else
                        const SizedBox(width: 16.0), // Padding if no back button
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0), // No extra left padding here
                        child: SizedBox(
                          height: 32.0,
                          child: title != null
                              ? Text( // No Align needed, it's naturally left within the Row
                                  title!,
                                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                )
                              : Image.asset(
                                  'assets/images/hubli_logo.png',
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ],
                  ),
                  Padding( // This is the right-aligned action icon group
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
