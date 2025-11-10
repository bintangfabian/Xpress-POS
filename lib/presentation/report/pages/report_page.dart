import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/components/empty_state.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/presentation/home/models/order_model.dart';
import 'package:xpress/presentation/report/pages/transaction_detail_page.dart';
import 'package:xpress/presentation/report/widgets/report_title.dart';

class ReportPage extends StatefulWidget {
  final Function(String orderId)? onOpenDetail;
  const ReportPage({super.key, this.onOpenDetail});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int selectedMenu = 0;
  String title = 'Summary Sales Report';
  DateTime fromDate = TimezoneHelper.now().subtract(const Duration(days: 30));
  DateTime toDate = TimezoneHelper.now();
  bool isOnline = true;
  bool hasOfflineData = false; // sementara: offline => tidak ada data
  List<ItemOrder> orders = [];
  bool isLoading = false;
  String? errorMessage;
  static const int _ordersBatchSize = 10;
  static const int _dateFetchBatchSize = 3;
  List<_DailyOrderSection> _dailySections = [];
  late final OrderRemoteDatasource _orderDatasource;

  void _logDebug(String message) {
    assert(() {
      developer.log(message, name: 'ReportPage');
      return true;
    }());
  }

  @override
  void initState() {
    super.initState();
    _orderDatasource = OrderRemoteDatasource();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
      _dailySections = [];
    });

    try {
      final dateKeys = _generateDateKeys();
      final List<_DailyOrderSection> sections = [];
      String? fetchError;

      for (var i = 0; i < dateKeys.length; i += _dateFetchBatchSize) {
        final batch = dateKeys.skip(i).take(_dateFetchBatchSize).toList();
        final batchResults = await Future.wait(
          batch.map((dateKey) => _fetchSectionForDate(dateKey)),
        );

        if (!mounted) return;

        for (final result in batchResults) {
          if (result.error != null) {
            fetchError = result.error;
            break;
          }
          if (result.section != null) {
            sections.add(result.section!);
          }
        }

        if (fetchError != null) break;
      }

      if (!mounted) return;

      if (fetchError != null) {
        setState(() {
          errorMessage = fetchError;
          orders = [];
          _dailySections = [];
        });
        return;
      }

      final flattenedOrders =
          sections.expand((section) => section.orders).toList();

      setState(() {
        orders = flattenedOrders;
        errorMessage = null;
        _dailySections = sections;
      });

      _logDebug('=== DEBUG ORDERS ===');
      for (var order in flattenedOrders) {
        _logDebug('Order ID: ${order.id}');
        _logDebug('Order Number: ${order.orderNumber}');
        _logDebug('Total Amount: ${order.totalAmount}');
        _logDebug('Table Number: ${order.table?.tableNumber}');
        _logDebug('Table Name: ${order.table?.name}');
        _logDebug('Status: ${order.status}');
        _logDebug('Payment Method (order level): ${order.paymentMethod}');
        _logDebug('Payments Array Length: ${order.payments?.length}');
        if (order.payments != null && order.payments!.isNotEmpty) {
          _logDebug(
              'First Payment Method: ${order.payments!.first.paymentMethod}');
        }
        _logDebug('Operation Mode: ${order.operationMode}');
        _logDebug('---');
      }
      _logDebug('Total orders: ${flattenedOrders.length}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Error: $e';
        orders = [];
        _dailySections = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  List<String> _generateDateKeys() {
    final List<String> keys = [];
    final DateTime startDate =
        DateTime(fromDate.year, fromDate.month, fromDate.day);
    DateTime cursor = DateTime(toDate.year, toDate.month, toDate.day);

    while (!cursor.isBefore(startDate)) {
      keys.add(DateFormat('yyyy-MM-dd').format(cursor));
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return keys;
  }

  Future<_DailyFetchResult> _fetchSectionForDate(String dateKey) async {
    final result = await _orderDatasource.getOrderByRangeDate(
      dateKey,
      dateKey,
      perPage: _ordersBatchSize,
      page: 1,
    );

    return result.fold(
      (error) => _DailyFetchResult(dateKey, error: error),
      (orderResponse) {
        final dayOrders = orderResponse.data ?? [];
        if (dayOrders.isEmpty) {
          return _DailyFetchResult(dateKey);
        }
        return _DailyFetchResult(
          dateKey,
          section: _DailyOrderSection(
            dateKey: dateKey,
            orders: dayOrders,
            visibleCount: math.min(_ordersBatchSize, dayOrders.length),
            currentPage: 1,
            hasMore: dayOrders.length == _ordersBatchSize,
          ),
        );
      },
    );
  }

  List<ItemOrder> _rebuildOrdersCache() {
    return _dailySections.expand((section) => section.orders).toList();
  }

  Future<void> _loadMoreOrdersForDate(String dateKey) async {
    if (!mounted) return;

    final sectionIndex =
        _dailySections.indexWhere((section) => section.dateKey == dateKey);
    if (sectionIndex == -1) return;

    final section = _dailySections[sectionIndex];

    final hasHiddenLocal = section.visibleCount < section.orders.length;
    if (hasHiddenLocal) {
      setState(() {
        section.visibleCount = math.min(
          section.visibleCount + _ordersBatchSize,
          section.orders.length,
        );
      });
      return;
    }

    if (!section.hasMore || section.isLoadingMore) return;

    setState(() {
      section.isLoadingMore = true;
    });

    final nextPage = section.currentPage + 1;
    final result = await _orderDatasource.getOrderByRangeDate(
      dateKey,
      dateKey,
      perPage: _ordersBatchSize,
      page: nextPage,
    );

    if (!mounted) return;

    result.fold(
      (error) {
        setState(() {
          section.isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
      (orderResponse) {
        final newOrders = orderResponse.data ?? [];
        setState(() {
          section.orders.addAll(newOrders);
          section.currentPage = nextPage;
          section.hasMore = newOrders.length == _ordersBatchSize;
          section.visibleCount = math.min(
            section.visibleCount + newOrders.length,
            section.orders.length,
          );
          section.isLoadingMore = false;
          orders = _rebuildOrdersCache();
        });
      },
    );
  }

  String _formatDateForDisplay(String dateKey) {
    try {
      final date = TimezoneHelper.toWib(DateTime.parse(dateKey));
      final now = TimezoneHelper.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (dateOnly == today) {
        return 'Hari Ini';
      } else if (dateOnly == yesterday) {
        return 'Kemarin';
      } else {
        return DateFormat('EEEE, d MMMM yyyy').format(date);
      }
    } catch (e) {
      return dateKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6, right: 6),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReportTitle(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (!isOnline) setState(() => isOnline = true);
                          },
                          child: Container(
                            height: 85,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: isOnline ? 5 : 3,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Transaksi Online",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            if (isOnline) setState(() => isOnline = false);
                          },
                          child: Container(
                            height: 85,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: !isOnline ? 5 : 3,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Transaksi Offline",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: isOnline
                        ? _buildOrdersList()
                        : (hasOfflineData
                            ? _buildOrdersList()
                            : _emptyOfflineState()),
                  ),
                  if (!isOnline && hasOfflineData) ...[
                    const SizedBox(height: 8),
                    Button.filled(
                      height: 52,
                      onPressed: () {},
                      icon: Assets.icons.sync.svg(
                        height: 20,
                        width: 20,
                        colorFilter:
                            ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                      ),
                      label: 'Transfer Data',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrders,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (orders.isEmpty) {
      return _emptyOnlineState();
    }

    if (_dailySections.isEmpty) {
      return _emptyOnlineState();
    }

    return ListView.builder(
      itemCount: _dailySections.length,
      itemBuilder: (context, index) {
        final section = _dailySections[index];
        final dayOrders = section.orders;
        final visibleOrders =
            dayOrders.take(section.visibleCount).toList();
        final canLoadMore =
            section.visibleCount < dayOrders.length || section.hasMore;

        return _getProductByDate(
          dateLabel: _formatDateForDisplay(section.dateKey),
          visibleOrders: visibleOrders,
          showLoadMore: canLoadMore,
          isLoadingMore: section.isLoadingMore,
          onLoadMore: () => _loadMoreOrdersForDate(section.dateKey),
        );
      },
    );
  }

  Widget _emptyOfflineState() {
    return EmptyState(
      icon: Assets.icons.deleteMinus,
      message: "Riwayat Transaksi Offline Telah Berhasil Disingkronisasi",
    );
  }

  Widget _emptyOnlineState() {
    return EmptyState(
        icon: Assets.icons.bill, message: "Tidak Ada Data Transaksi");
  }

  Widget _getProductByDate({
    required String dateLabel,
    required List<ItemOrder> visibleOrders,
    required bool showLoadMore,
    required bool isLoadingMore,
    required VoidCallback onLoadMore,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          margin: EdgeInsets.only(top: 4),
          height: 56,
          decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              dateLabel,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...visibleOrders.map((order) => _getProductListByDate(order)),
        if (showLoadMore)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Button.outlined(
              height: 44,
              onPressed: onLoadMore,
              disabled: isLoadingMore,
              label: isLoadingMore ? 'Loading...' : 'Load More',
            ),
          ),
      ],
    );
  }

  Widget _getProductListByDate(ItemOrder order) {
    // Format waktu dari createdAt
    String timeStr = '';
    if (order.createdAt != null) {
      final dateTime = TimezoneHelper.toWib(order.createdAt!);
      timeStr = DateFormat('HH.mm').format(dateTime);
    }

    // Get payment method from order or from payments array
    String paymentMethod = order.paymentMethod ?? '';
    if (paymentMethod.isEmpty &&
        order.payments != null &&
        order.payments!.isNotEmpty) {
      // Get payment method from the first payment in the payments array
      paymentMethod = order.payments!.first.paymentMethod ?? '';
    }

    // Debug logging
    _logDebug(
        'Order ${order.orderNumber}: paymentMethod=${order.paymentMethod}, paymentsArray=${order.payments?.length}, finalPaymentMethod=$paymentMethod, operationMode=${order.operationMode}');

    // Tentukan icon berdasarkan payment method
    Widget paymentIcon = Assets.icons.tunai.svg(
      colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      height: 46,
      width: 46,
    );
    final paymentMethodLower = paymentMethod.toLowerCase();
    if (paymentMethodLower == 'qris' ||
        paymentMethodLower == 'qr' ||
        paymentMethodLower == 'digital' ||
        paymentMethodLower == 'transfer' ||
        paymentMethodLower == 'debit' ||
        paymentMethodLower == 'credit') {
      paymentIcon = Assets.icons.nonTunai.svg(
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        height: 46,
        width: 46,
      );
    }

    // Tentukan warna status
    Color statusColor = AppColors.success;
    Color statusBgColor = AppColors.successLight;
    String statusText = 'Lunas';

    if (order.status?.toLowerCase() == 'pending' ||
        order.status?.toLowerCase() == 'open') {
      statusColor = AppColors.warning;
      statusBgColor = AppColors.warningLight;
      statusText = 'Pending';
    } else if (order.status?.toLowerCase() == 'cancelled') {
      statusColor = AppColors.danger;
      statusBgColor = AppColors.dangerLight;
      statusText = 'Batal';
    }

    return InkWell(
      onTap: () {
        _logDebug('=== DEBUG ORDER CLICK ===');
        _logDebug('Order: $order');
        _logDebug('Order ID: ${order.id}');
        _logDebug('Order Number: ${order.orderNumber}');
        _logDebug('Order ID is null: ${order.id == null}');
        _logDebug('Order ID is empty: ${order.id?.isEmpty ?? true}');
        _logDebug('========================');

        if (widget.onOpenDetail != null) {
          if (order.id != null && order.id!.isNotEmpty) {
            widget.onOpenDetail!.call(order.id!);
          } else {
            _logDebug(
                'ERROR: Order ID is null or empty, cannot open detail page');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Order ID tidak valid')),
            );
          }
        } else {
          if (order.id != null && order.id!.isNotEmpty) {
            // Try to use existing order data first, but fetch detail if needed
            _logDebug('=== NAVIGATING TO DETAIL PAGE ===');
            _logDebug('Passing order: $order');
            _logDebug('Passing orderId: ${order.id}');
            _logDebug('Order ID type: ${order.id.runtimeType}');
            _logDebug('Order ID is null: ${order.id == null}');
            _logDebug('Order ID is empty: ${order.id?.isEmpty ?? true}');
            _logDebug('Order ID length: ${order.id?.length}');
            _logDebug('=================================');

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionDetailPage(
                  orderId: order.id, // Only pass orderId, fetch detail
                ),
              ),
            );
          } else {
            _logDebug(
                'ERROR: Order ID is null or empty, cannot open detail page');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Order ID tidak valid')),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        margin: EdgeInsets.symmetric(vertical: 6),
        height: 70,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            border: Border.all(width: 2, color: AppColors.greyLight)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    paymentIcon,
                    const SizedBox(
                      width: 8,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Rp ${NumberFormat('#,###').format((double.tryParse(order.totalAmount ?? '0') ?? 0).toInt())}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              timeStr,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              width: 24,
                            ),
                            Text(
                              order.table?.tableNumber != null &&
                                      order.table!.tableNumber!.isNotEmpty
                                  ? "Meja ${order.table!.tableNumber}"
                                  : "",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft, // area tetap nempel kiri
                child: FractionallySizedBox(
                  widthFactor: 0.75, // sesuaikan jika mau lebih/kurang lebar
                  alignment: Alignment.center, // teks dipusatkan dalam area tsb
                  child: Text(
                    operationModeLabel(order.operationMode),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  alignment: Alignment.center,
                  child: Text(
                    paymentMethod.isNotEmpty
                        ? paymentMethod.toUpperCase()
                        : 'TUNAI',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: 106,
                height: 37,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                child: Text(
                  statusText,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyOrderSection {
  final String dateKey;
  final List<ItemOrder> orders;
  int visibleCount;
  int currentPage;
  bool hasMore;
  bool isLoadingMore;

  _DailyOrderSection({
    required this.dateKey,
    required this.orders,
    required this.visibleCount,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });
}

class _DailyFetchResult {
  final String dateKey;
  final _DailyOrderSection? section;
  final String? error;

  _DailyFetchResult(this.dateKey, {this.section, this.error});
}
