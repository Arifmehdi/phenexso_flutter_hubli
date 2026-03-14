import 'package:flutter/material.dart';
import 'package:hubli/models/order.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RiderOrderDetailScreen extends StatelessWidget {
  final Order order;

  const RiderOrderDetailScreen({super.key, required this.order});

  Future<void> _printInvoice(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('HUBLI - INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Order #${order.id}', style: pw.TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Customer Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('Name: ${order.name}'),
                      pw.Text('Mobile: ${order.mobile}'),
                      pw.Text('Email: ${order.email ?? 'N/A'}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Order Date: ${DateFormat('dd MMM yyyy').format(order.orderDate)}'),
                      pw.Text('Payment Method: ${order.paymentMethod}'),
                      pw.Text('Payment Status: ${order.paymentStatus.toUpperCase()}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Shipping Address:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(order.addressTitle),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headers: ['Product Name', 'Quantity', 'Price', 'Total'],
                data: List<List<String>>.from(order.items.map((item) => [
                  item.productName,
                  item.quantity.toString(),
                  'Tk ${item.productPrice.toStringAsFixed(2)}',
                  'Tk ${item.totalCost.toStringAsFixed(2)}'
                ])),
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Subtotal: Tk ${order.subtotal.toStringAsFixed(2)}'),
                      pw.Text('Delivery Cost: Tk ${order.deliveryCost.toStringAsFixed(2)}'),
                      pw.Divider(),
                      pw.Text('Grand Total: Tk ${order.grandTotal.toStringAsFixed(2)}', 
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              if (order.orderNote != null && order.orderNote!.isNotEmpty) ...[
                pw.SizedBox(height: 20),
                pw.Text('Note:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(order.orderNote!),
              ],
              pw.SizedBox(height: 40),
              pw.Center(child: pw.Text('Thank you for shopping with Hubli!')),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Hubli_Invoice_${order.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print Invoice',
            onPressed: () => _printInvoice(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Order Status', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(order.paymentStatus.toUpperCase(), 
                        style: TextStyle(
                          color: order.paymentStatus == 'paid' ? Colors.green : Colors.orange, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 18
                        )),
                    ],
                  ),
                  const Icon(Icons.receipt_long, size: 40, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Info
            _buildSectionTitle('Customer Information'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person, 'Name', order.name),
                    _buildInfoRow(Icons.phone, 'Mobile', order.mobile),
                    _buildInfoRow(Icons.email, 'Email', order.email ?? 'N/A'),
                    _buildInfoRow(Icons.location_on, 'Address', order.addressTitle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order Items
            _buildSectionTitle('Items Ordered'),
            ...order.items.map((item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(item.productName),
                subtitle: Text('Qty: ${item.quantity} x ৳ ${item.productPrice.toStringAsFixed(2)}'),
                trailing: Text('৳ ${item.totalCost.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            )),
            const SizedBox(height: 16),

            // Price Summary
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', order.subtotal),
                    _buildSummaryRow('Delivery Fee', order.deliveryCost),
                    const Divider(height: 24),
                    _buildSummaryRow('Grand Total', order.grandTotal, isBold: true),
                  ],
                ),
              ),
            ),

            if (order.orderNote != null && order.orderNote!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Order Note'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(order.orderNote!),
                ),
              ),
            ],
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _printInvoice(context),
                icon: const Icon(Icons.print),
                label: const Text('Print as Invoice'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        Text('৳ ${amount.toStringAsFixed(2)}', 
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal, 
            fontSize: isBold ? 18 : 14,
            color: isBold ? Colors.green : Colors.black
          )),
      ],
    );
  }
}
