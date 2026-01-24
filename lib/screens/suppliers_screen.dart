import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubli/data/placeholder_data.dart';
import 'package:hubli/models/supplier.dart';
import 'package:hubli/utils/colors.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Supplier Management',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appColorsPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dummySuppliers.length,
              itemBuilder: (context, index) {
                final Supplier supplier = dummySuppliers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.people, color: appColorsPrimary),
                    title: Text(
                      supplier.name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact: ${supplier.contactPerson}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Email: ${supplier.email}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Phone: ${supplier.phone}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Address: ${supplier.address}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement navigation to supplier detail screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on ${supplier.name}')),
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
          // TODO: Implement add new supplier functionality
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add New Supplier')));
        },
        backgroundColor: appColorsPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
