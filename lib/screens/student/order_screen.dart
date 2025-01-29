import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path/path.dart' as path;

import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../utils/message_dialog.dart';
import '../../widgets/order_history/filter_section.dart';
import '../../widgets/order_history/order_card.dart';

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
  late final NumberFormat _currencyFormatter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    _loadOrders(useCache: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 1000 &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _loadOrders(forceRefresh: true);
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

  Future<void> _handleWebDownload(int orderId, BuildContext context) async {
    if (!mounted) return;
    final bytes = await Provider.of<OrderService>(context, listen: false)
        .downloadReceipt(orderId);

    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'school_canteen_receipt_$orderId.pdf';

    html.document.body?.children.add(anchor);
    anchor.click();

    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    if (!context.mounted) return;
    showMessageDialog(
      context,
      'Success',
      'Receipt downloaded successfully',
    );
  }

  Future<void> _handleMobileDownload(int orderId, BuildContext context) async {
    final permissionResult = await Permission.storage.request();
    if (!permissionResult.isGranted) return;

    if (!context.mounted) return;
    final bytes = await Provider.of<OrderService>(context, listen: false)
        .downloadReceipt(orderId);

    final appDir = await getApplicationDocumentsDirectory();
    final receiptDir = Directory('${appDir.path}/school_canteen_receipt');

    if (!await receiptDir.exists()) {
      await receiptDir.create(recursive: true);
    }

    final fileName = 'receipt_$orderId.pdf';
    final filePath = path.join(receiptDir.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes as List<int>);

    if (!context.mounted) return;
    showMessageDialog(
      context,
      'Success',
      'Receipt downloaded successfully.\n\nFile saved at: school_canteen_receipt/$fileName',
    );

    await OpenFile.open(file.path);
  }

  Future<void> _downloadReceipt(BuildContext context, int orderId) async {
    setState(() {
      _loadingOrders[orderId] = true;
    });

    try {
      if (kIsWeb) {
        await _handleWebDownload(orderId, context);
      } else {
        await _handleMobileDownload(orderId, context);
      }
    } catch (e) {
      if (!context.mounted) return;
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

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                height: 20,
                width: 150,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 16,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.clipboardList,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your filters or pull to refresh',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(LucideIcons.rotateCcw),
            label: const Text('Reset Filters'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
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
        centerTitle: false,
      ),
      body: Column(
        children: [
          FilterSection(
            selectedMonth: _selectedMonth,
            selectedYear: _selectedYear,
            onMonthChanged: (value) {
              setState(() => _selectedMonth = value);
              _loadOrders();
            },
            onYearChanged: (value) {
              setState(() => _selectedYear = value);
              _loadOrders();
            },
            onClearFilters: _clearFilters,
            currentYear: currentYear,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _isLoading && _orders.isEmpty
                  ? _buildLoadingShimmer()
                  : _orders.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) => OrderCard(
                            order: _orders[index],
                            isLoading:
                                _loadingOrders[_orders[index].id] ?? false,
                            onDownload: _downloadReceipt,
                            currencyFormatter: _currencyFormatter,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
