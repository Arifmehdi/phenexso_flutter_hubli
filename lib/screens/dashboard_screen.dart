import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hubli/data/placeholder_data.dart';
import 'package:hubli/utils/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int totalInventory = dummyInventoryItems.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
    final int pendingOrders = dummyOrders
        .where((order) => order.status == 'Pending')
        .length;
    final int inTransitShipments = dummyShipments
        .where((shipment) => shipment.status == 'In Transit')
        .length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: appColorsPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                _buildDashboardCard(
                  context,
                  title: 'Total Inventory',
                  value: totalInventory.toString(),
                  icon: Icons.inventory_2,
                  color: Colors.blue.shade300,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Pending Orders',
                  value: pendingOrders.toString(),
                  icon: Icons.receipt_long,
                  color: Colors.orange.shade300,
                ),
                _buildDashboardCard(
                  context,
                  title: 'In-Transit Shipments',
                  value: inTransitShipments.toString(),
                  icon: Icons.local_shipping,
                  color: Colors.purple.shade300,
                ),
                _buildDashboardCard(
                  context,
                  title: 'Total Suppliers',
                  value: dummySuppliers.length.toString(),
                  icon: Icons.people,
                  color: Colors.green.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
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
