import 'dart:developer' as developer;

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

  void _logDebug(String message) {
    assert(() {
      developer.log(message, name: 'ReportPage');
      return true;
    }());
  }

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final orderDatasource = OrderRemoteDatasource();
      final result = await orderDatasource.getOrderByRangeDate(
        DateFormat('yyyy-MM-dd').format(fromDate),
        DateFormat('yyyy-MM-dd').format(toDate),
      );

      result.fold(
        (error) {
          setState(() {
            errorMessage = error;
            orders = [];
          });
        },
        (orderResponse) {
          setState(() {
            orders = orderResponse.data ?? [];
            errorMessage = null;
          });

          // Debug print untuk melihat data
          _logDebug('=== DEBUG ORDERS ===');
          for (var order in orders) {
            _logDebug('Order ID: ${order.id}');
            _logDebug('Total Amount: ${order.totalAmount}');
            _logDebug('Table Number: ${order.table?.tableNumber}');
            _logDebug('Table Name: ${order.table?.name}');
            _logDebug('Status: ${order.status}');
            _logDebug('---');
          }
          _logDebug('Total orders: ${orders.length}');
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        orders = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Map<String, List<ItemOrder>> _groupOrdersByDate() {
    Map<String, List<ItemOrder>> groupedOrders = {};

    for (var order in orders) {
      if (order.createdAt != null) {
        final date = TimezoneHelper.toWib(order.createdAt!);
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        if (!groupedOrders.containsKey(dateKey)) {
          groupedOrders[dateKey] = [];
        }
        groupedOrders[dateKey]!.add(order);
      }
    }

    return groupedOrders;
  }

  double _calculateDailyTotal(List<ItemOrder> dayOrders) {
    return dayOrders.fold(
        0.0,
        (sum, order) =>
            sum + (double.tryParse(order.totalAmount ?? '0') ?? 0.0));
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

    final groupedOrders = _groupOrdersByDate();
    final sortedDates = groupedOrders.keys.toList()
      ..sort((a, b) {
        // Parse dates from the formatted strings (yyyy-MM-dd)
        final dateA = DateTime.parse(a);
        final dateB = DateTime.parse(b);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      itemCount: groupedOrders.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dayOrders = groupedOrders[date]!;
        final dailyTotal = _calculateDailyTotal(dayOrders);

        return _getProductByDate(
          _formatDateForDisplay(date),
          'Rp ${NumberFormat('#,###').format(dailyTotal.toInt())}',
          dayOrders,
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

  Widget _getProductByDate(
      String date, String income, List<ItemOrder> dayOrders) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          margin: EdgeInsets.only(top: 4),
          height: 56,
          decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                income,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        ...dayOrders.map((order) => _getProductListByDate(order)),
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

    // Tentukan icon berdasarkan payment method
    Widget paymentIcon = Assets.icons.tunai.svg(
      colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      height: 46,
      width: 46,
    );
    if (order.paymentMethod?.toLowerCase() == 'qris') {
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

    if (order.status?.toLowerCase() == 'pending') {
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
              flex: 3,
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
              child: Text(
                operationModeLabel(order.operationMode),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                order.paymentMethod?.toUpperCase() ?? "TUNAI",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
