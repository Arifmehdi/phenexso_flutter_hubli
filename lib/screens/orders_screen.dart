import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubli/data/placeholder_data.dart';
import 'package:hubli/models/order.dart';
import 'package:hubli/utils/colors.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Order Management',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appColorsPrimary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dummyOrders.length,
              itemBuilder: (context, index) {
                final Order order = dummyOrders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.receipt_long,
                      color: appColorsPrimary,
                    ),
                    title: Text(
                      'Order ID: ${order.id}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer: ${order.customerName}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Date: ${DateFormat.yMMMd().format(order.orderDate)}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Total: BDT ${order.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          'Status: ${order.status}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // TODO: Implement navigation to order detail screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tapped on Order ${order.id}')),
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
          // TODO: Implement add new order functionality
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Add New Order')));
        },
        backgroundColor: appColorsPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
