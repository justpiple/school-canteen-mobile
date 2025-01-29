import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../utils/message_dialog.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool _isLoading = false;
  List<Order> _orders = [];
  int? _selectedMonth;
  int? _selectedYear;
  final Map<int, bool> _loadingOrders = {};
  final currentYear = DateTime.now().year;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrders(useCache: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 1000) {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadOrders(forceRefresh: true);
      }
    }
  }

  Future<void> _loadOrders(
      {bool forceRefresh = false, bool useCache = false}) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final queryParams = <String, dynamic>{};
      if (_selectedMonth != null) queryParams['month'] = _selectedMonth;
      if (_selectedYear != null) queryParams['year'] = _selectedYear;

      final response =
          await Provider.of<OrderService>(context, listen: false).getOrders(
        queryParams: queryParams,
        forceRefresh: forceRefresh && !useCache,
      );

      if (response.isSuccess) {
        setState(() => _orders = response.data?.orders ?? []);
      } else {
        if (!mounted) return;
        showMessageDialog(
          context,
          'Error',
          'Failed to load orders: ${response.message}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      showMessageDialog(
        context,
        'Error',
        'An unexpected error occurred while loading orders',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await _loadOrders(forceRefresh: true);
  }

  void _clearFilters() {
    setState(() {
      _selectedMonth = null;
      _selectedYear = currentYear;
    });
    _loadOrders();
  }

  Future<void> _downloadReceipt(int orderId) async {
    setState(() {
      _loadingOrders[orderId] = true;
    });

    try {
      PermissionStatus permissionResult = await Permission.storage.request();

      if (!context.mounted) return;

      if (permissionResult.isGranted) {
        final bytes = await Provider.of<OrderService>(context, listen: false)
            .downloadReceipt(orderId);

        final filePath = '/storage/emulated/0/Download/receipt_$orderId.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes as List<int>);

        if (!mounted) return;
        showMessageDialog(
          context,
          'Success',
          'Receipt downloaded successfully.\n\nFile saved at: Downloads/receipt_$orderId.pdf',
        );

        await OpenFile.open(file.path);
      }
    } catch (e) {
      if (!mounted) return;
      showMessageDialog(
        context,
        'Error',
        'Failed to download receipt',
      );
    } finally {
      setState(() {
        _loadingOrders[orderId] = false;
      });
    }
  }

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
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

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Month',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              value: _selectedMonth,
              hint: const Text('Select month'),
              icon: const Icon(Icons.keyboard_arrow_down),
              menuMaxHeight: 300,
              isExpanded: true,
              items: List.generate(12, (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(
                    DateFormat('MMMM').format(DateTime(2024, index + 1)),
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }),
              onChanged: (value) {
                setState(() => _selectedMonth = value);
                _loadOrders();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Year',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              value: _selectedYear ?? currentYear,
              icon: const Icon(Icons.keyboard_arrow_down),
              isExpanded: true,
              items: List.generate(5, (index) {
                final year = currentYear - index;
                return DropdownMenuItem(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: const TextStyle(fontSize: 15),
                  ),
                );
              }),
              onChanged: (value) {
                setState(() => _selectedYear = value);
                _loadOrders();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _clearFilters,
            icon: const Icon(LucideIcons.x),
            tooltip: 'Clear filters',
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final totalAmount = order.items.fold<double>(
      0,
      (sum, item) => sum + item.price,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(order.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMMM yyyy, HH:mm').format(order.createdAt),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  LucideIcons.store,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  order.standName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Row(
            children: [
              Text(
                _formatCurrency(totalAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${order.items.length} items',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map<Widget>((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item.menuName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'x${item.quantity}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _formatCurrency(item.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadingOrders[order.id] == true
                        ? null
                        : () => _downloadReceipt(order.id),
                    icon: _loadingOrders[order.id] == true
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(LucideIcons.download, size: 18),
                    label: Text(
                      _loadingOrders[order.id] == true
                          ? 'Downloading...'
                          : 'Download Receipt',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.clipboardList,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Order History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _isLoading && _orders.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _orders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) =>
                              _buildOrderCard(_orders[index]),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
