import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/order.dart';
import '../../services/order_service.dart';
import 'order_details_section.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final bool isLoading;
  final Function(BuildContext, int) onDownload;
  final NumberFormat currencyFormatter;
  final bool isAdmin;

  const OrderCard({
    required this.order,
    required this.isLoading,
    required this.onDownload,
    required this.currencyFormatter,
    this.isAdmin = false,
    super.key,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order.status;
  }

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

  String _getNextStatusText(String currentStatus) {
    switch (currentStatus) {
      case 'PENDING':
        return 'Start Cooking';
      case 'COOKING':
        return 'Send for Delivery';
      case 'ON_DELIVERY':
        return 'Complete Order';
      default:
        return '';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return LucideIcons.chefHat;
      case 'COOKING':
        return LucideIcons.bike;
      case 'ON_DELIVERY':
        return LucideIcons.checkCircle;
      default:
        return LucideIcons.helpCircle;
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String nextStatus) async {
    final buttonText = _getNextStatusText(currentStatus);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getStatusIcon(nextStatus),
                color: _getStatusColor(nextStatus)),
            const SizedBox(width: 8),
            const Text('Update Order Status'),
          ],
        ),
        content: Text(
          'Are you sure you want to "$buttonText" for Order #${widget.order.id}?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              backgroundColor: _getStatusColor(nextStatus),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Yes, $buttonText'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (!context.mounted) return;
        final response = await Provider.of<OrderService>(context, listen: false)
            .updateOrder(widget.order.id.toString(), nextStatus);

        if (!response.isSuccess) {
          throw response.message;
        }

        setState(() {
          currentStatus = nextStatus;
        });
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Order #${widget.order.id} status updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString() ??
                'Failed to update Order #${widget.order.id} status'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Widget _buildAdminActions(BuildContext context) {
    if (currentStatus == 'COMPLETED') {
      return const SizedBox.shrink();
    }

    String nextStatus;
    switch (currentStatus) {
      case 'PENDING':
        nextStatus = 'COOKING';
        break;
      case 'COOKING':
        nextStatus = 'ON_DELIVERY';
        break;
      case 'ON_DELIVERY':
        nextStatus = 'COMPLETED';
        break;
      default:
        return const SizedBox.shrink();
    }

    return _buildUpdateStatusButton(context, nextStatus);
  }

  Widget _buildUpdateStatusButton(BuildContext context, String nextStatus) {
    final statusColor = _getStatusColor(nextStatus);
    final buttonText = _getNextStatusText(currentStatus);
    final icon = _getStatusIcon(nextStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => _showConfirmationDialog(context, nextStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: statusColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withAlpha(26),
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
                'Order #${widget.order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMMM yyyy, HH:mm')
                    .format(widget.order.createdAt),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(currentStatus),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = widget.order.items.fold<double>(
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
                    label: widget.order.standName,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    icon: LucideIcons.utensils,
                    label: '${widget.order.items.length} items',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.currencyFormatter.format(totalAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (widget.isAdmin) ...[
                const SizedBox(height: 12),
                _buildAdminActions(context),
              ],
            ],
          ),
          children: [
            OrderDetailsSection(
              order: widget.order,
              isLoading: widget.isLoading,
              onDownload: widget.onDownload,
              currencyFormatter: widget.currencyFormatter,
            ),
          ],
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
}
