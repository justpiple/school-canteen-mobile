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
  bool isUpdatingStatus = false;

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
        return LucideIcons.clock;
      case 'COOKING':
        return LucideIcons.chefHat;
      case 'ON_DELIVERY':
        return LucideIcons.truck;
      default:
        return LucideIcons.checkCircle;
    }
  }

  Future<void> _showConfirmationDialog(
      BuildContext context, String nextStatus) async {
    final buttonText = _getNextStatusText(currentStatus);
    final statusColor = _getStatusColor(nextStatus);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(_getStatusIcon(nextStatus), color: statusColor),
            const SizedBox(width: 12),
            const Text(
              'Update Order Status',
              style: TextStyle(fontSize: 18),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: statusColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Yes, $buttonText',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateOrderStatus(nextStatus);
    }
  }

  Future<void> _updateOrderStatus(String nextStatus) async {
    setState(() {
      isUpdatingStatus = true;
    });

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
      _showSuccessSnackBar();
    } catch (e) {
      if (!context.mounted) return;
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() {
        isUpdatingStatus = false;
      });
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #${widget.order.id} status updated successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showErrorSnackBar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            // ignore: dead_null_aware_expression
            Text(error ?? 'Failed to update Order #${widget.order.id} status'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: isUpdatingStatus
            ? null
            : () => _showConfirmationDialog(context, nextStatus),
        style: ElevatedButton.styleFrom(
          backgroundColor: statusColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          disabledBackgroundColor: statusColor.withAlpha(120),
        ),
        child: isUpdatingStatus
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Updating Status...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                LucideIcons.shoppingBag,
                size: 24,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${widget.order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('dd MMM yyyy • HH:mm')
                        .format(widget.order.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatusBadge(currentStatus),
      ],
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildInfoChip(
          icon: LucideIcons.store,
          label: widget.order.standName,
        ),
        _buildInfoChip(
          icon: LucideIcons.utensils,
          label: '${widget.order.items.length} items',
        ),
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
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(12),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          expandedAlignment: Alignment.topLeft,
          backgroundColor: Colors.transparent,
          title: _buildOrderHeader(context),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildInfoChips(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    widget.currencyFormatter.format(totalAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              if (widget.isAdmin) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: _buildAdminActions(context),
                ),
              ],
            ],
          ),
          children: [
            OrderDetailsSection(
              order: widget.order,
              isLoading: widget.isLoading,
              onDownload: widget.onDownload,
              currencyFormatter: widget.currencyFormatter,
              isAdmin: widget.isAdmin,
            ),
          ],
        ),
      ),
    );
  }
}
