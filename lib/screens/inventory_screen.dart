import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubli/data/placeholder_data.dart';
import 'package:hubli/models/inventory_item.dart';
import 'package:hubli/utils/colors.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Inventory Management',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appColorsPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dummyInventoryItems.length,
              itemBuilder: (context, index) {
                final InventoryItem item = dummyInventoryItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.category,
                      color: appColorsPrimary,
                    ),
                    title: Text(
                      item.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SKU: ${item.sku}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Quantity: ${item.quantity}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Price: BDT ${item.price.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Location: ${item.location}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement navigation to item detail screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on ${item.name}')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new inventory item functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add New Inventory Item')),
          );
        },
        backgroundColor: appColorsPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
