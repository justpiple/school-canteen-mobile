import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../models/order.dart';
import 'order_item_tile.dart';

class OrderDetailsSection extends StatelessWidget {
  final Order order;
  final bool isLoading;
  final Function(BuildContext, int) onDownload;
  final NumberFormat currencyFormatter;
  final bool isAdmin;

  const OrderDetailsSection({
    required this.order,
    required this.isLoading,
    required this.onDownload,
    required this.currencyFormatter,
    required this.isAdmin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Order Items',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => OrderItemTile(
                item: item,
                currencyFormatter: currencyFormatter,
              )),
          const SizedBox(height: 16),
          _buildOrderSummary(subtotal),
          const SizedBox(height: 20),
          if (!isAdmin) _buildDownloadButton(context),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Subtotal',
            style: TextStyle(fontSize: 14),
          ),
          Text(
            currencyFormatter.format(subtotal),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : () => onDownload(context, order.id),
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(
                LucideIcons.download,
                color: Colors.white,
              ),
        label: Text(
          isLoading ? 'Downloading...' : 'Download Receipt',
          style: const TextStyle(fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
