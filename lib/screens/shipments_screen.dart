import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubli/data/placeholder_data.dart';
import 'package:hubli/models/shipment.dart';
import 'package:hubli/utils/colors.dart';
import 'package:intl/intl.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Shipment Tracking',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appColorsPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dummyShipments.length,
              itemBuilder: (context, index) {
                final Shipment shipment = dummyShipments[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.local_shipping,
                      color: appColorsPrimary,
                    ),
                    title: Text(
                      'Tracking No: ${shipment.trackingNumber}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Carrier: ${shipment.carrier}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Origin: ${shipment.origin}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Destination: ${shipment.destination}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Status: ${shipment.status}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _getStatusColor(shipment.status),
                          ),
                        ),
                        if (shipment.deliveryDate != null)
                          Text(
                            'Delivered: ${DateFormat.yMMMd().format(shipment.deliveryDate!)}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement navigation to shipment detail screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tapped on Tracking No: ${shipment.trackingNumber}',
                          ),
                        ),
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
          // TODO: Implement add new shipment functionality
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add New Shipment')));
        },
        backgroundColor: appColorsPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Transit':
        return Colors.blue;
      case 'Delivered':
        return Colors.green;
      case 'Manifested':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
