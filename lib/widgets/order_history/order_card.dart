import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../models/order.dart';
import 'order_details_section.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isLoading;
  final Function(BuildContext, int) onDownload;
  final NumberFormat currencyFormatter;

  const OrderCard({
    required this.order,
    required this.isLoading,
    required this.onDownload,
    required this.currencyFormatter,
    super.key,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'COOKING':
        return Colors.blue;
      case 'ON_DELIVERY':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withValues(alpha: .3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.shoppingBag,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMMM yyyy, HH:mm').format(order.createdAt),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(order.status),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = order.items.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: EdgeInsets.zero,
          expandedAlignment: Alignment.topLeft,
          backgroundColor: Colors.transparent,
          title: _buildOrderHeader(context),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    icon: LucideIcons.store,
                    label: order.standName,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: LucideIcons.utensils,
                    label: '${order.items.length} items',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                currencyFormatter.format(totalAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          children: [
            OrderDetailsSection(
              order: order,
              isLoading: isLoading,
              onDownload: onDownload,
              currencyFormatter: currencyFormatter,
            ),
          ],
        ),
      ),
    );
  }
}
