import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../services/discount_service.dart';
import '../../models/stand/discount.dart';
import '../../utils/snackbar.dart';
import 'discount_form_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ManageDiscountPage extends StatefulWidget {
  const ManageDiscountPage({super.key});

  @override
  State<ManageDiscountPage> createState() => _ManageDiscountPageState();
}

class _ManageDiscountPageState extends State<ManageDiscountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Discounts'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: "Add discount",
            onPressed: _showAddDiscountDialog,
          ),
        ],
      ),
      body: Consumer<DiscountService>(
        builder: (context, discountService, child) {
          return FutureBuilder(
            future: discountService.getDiscounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              final discounts = snapshot.data?.data ?? [];
              return discounts.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshDiscounts,
                      child: _buildResponsiveDiscountList(discounts),
                    );
            },
          );
        },
      ),
    );
  }

  Widget _buildResponsiveDiscountList(List<Discount> discounts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth =
            constraints.maxWidth > 600 ? 600 : constraints.maxWidth;

        return Center(
          child: SizedBox(
            width: maxWidth,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: discounts.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildDiscountCard(discounts[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _refreshDiscounts() async {
    final discountService =
        Provider.of<DiscountService>(context, listen: false);
    await discountService.getDiscounts(forceRefresh: true);
    setState(() {});
  }

  Widget _buildDiscountCard(Discount discount) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => _showEditDiscountDialog(discount),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: LucideIcons.edit,
            label: 'Edit',
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
          ),
          SlidableAction(
            onPressed: (context) => _deleteDiscount(discount),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: LucideIcons.trash2,
            label: 'Delete',
            borderRadius:
                const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showEditDiscountDialog(discount),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        discount.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${discount.percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.calendar,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${DateFormat('d MMM y').format(discount.startDate)} - ${DateFormat('d MMM y').format(discount.endDate)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteDiscount(Discount discount) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete Discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${discount.name}"?'),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        if (!mounted) return;
        final discountService =
            Provider.of<DiscountService>(context, listen: false);
        final response = await discountService.deleteDiscount(discount.id);

        if (response.isSuccess) {
          _showSnackbar('Discount deleted successfully', isSuccess: true);
          setState(() {});
        } else {
          // ignore: dead_null_aware_expression
          _showSnackbar(response.message ?? 'Failed to delete discount',
              isSuccess: false);
        }
      } catch (e) {
        _showSnackbar('An error occurred while deleting the discount',
            isSuccess: false);
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.tag,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'No discounts found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddDiscountDialog,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add First Discount'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDiscountDialog() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DiscountFormPage(),
      ),
    ).then((value) {
      if (value == true) {
        setState(() {});
      }
    });
  }

  void _showEditDiscountDialog(Discount discount) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Loading Discount Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we fetch the information',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  backgroundColor: Colors.green.withValues(alpha: .1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      final discountService =
          Provider.of<DiscountService>(context, listen: false);
      final detailedDiscount =
          await discountService.getDiscountById(discount.id);

      if (!mounted) return;
      Navigator.pop(context);

      if (detailedDiscount.data == null) {
        _showSnackbar('Failed to load discount details', isSuccess: false);
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiscountFormPage(
            discount: detailedDiscount.data,
          ),
        ),
      ).then((value) {
        if (value == true) {
          setState(() {});
        }
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackbar('An error occurred while loading discount details',
          isSuccess: false);
    }
  }

  void _showSnackbar(String message, {bool isSuccess = true}) {
    showSnackBar(context, isSuccess ? "Success" : "Error", message);
  }
}
