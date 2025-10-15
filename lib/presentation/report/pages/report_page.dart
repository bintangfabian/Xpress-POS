import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/presentation/report/widgets/report_title.dart';
import 'package:flutter/material.dart';
import 'package:xpress/presentation/report/pages/transaction_detail_page.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/models/response/order_remote_datasource.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  final Function(String orderId)? onOpenDetail;
  const ReportPage({super.key, this.onOpenDetail});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int selectedMenu = 0;
  String title = 'Summary Sales Report';
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime toDate = DateTime.now();
  bool isOnline = true;
  bool hasOfflineData = false; // sementara: offline => tidak ada data
  List<ItemOrder> orders = [];
  bool isLoading = false;
  String? errorMessage;

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
          print('=== DEBUG ORDERS ===');
          for (var order in orders) {
            print('Order ID: ${order.id}');
            print('Total Amount: ${order.totalAmount}');
            print('Table Number: ${order.table?.tableNumber}');
            print('Table Name: ${order.table?.name}');
            print('Status: ${order.status}');
            print('---');
          }
          print('Total orders: ${orders.length}');
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
        final date = order.createdAt!;
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
      final date = DateTime.parse(dateKey);
      final now = DateTime.now();
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
                            : _buildEmptyOfflineState()),
                  ),
                  if (!isOnline && hasOfflineData) ...[
                    const SizedBox(height: 8),
                    Button.filled(
                      height: 52,
                      onPressed: () {},
                      icon: Assets.icons.sync
                          .svg(height: 20, width: 20, color: AppColors.white),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Tidak ada data order',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
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

  Widget _buildEmptyOfflineState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.deleteMinus
              .svg(height: 128, width: 128, color: AppColors.primary),
          const SizedBox(height: 12),
          const Text(
            'Riwayat Transaksi Offline Telah Berhasil Disingkronisasi',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
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
      final dateTime = order.createdAt!;
      timeStr = DateFormat('HH.mm').format(dateTime);
    }

    // Tentukan icon berdasarkan payment method
    Widget paymentIcon =
        Assets.icons.tunai.svg(color: AppColors.primary, height: 46, width: 46);
    if (order.paymentMethod?.toLowerCase() == 'qris') {
      paymentIcon = Assets.icons.nonTunai
          .svg(color: AppColors.primary, height: 46, width: 46);
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
        print('=== DEBUG ORDER CLICK ===');
        print('Order: $order');
        print('Order ID: ${order.id}');
        print('Order Number: ${order.orderNumber}');
        print('Order ID is null: ${order.id == null}');
        print('Order ID is empty: ${order.id?.isEmpty ?? true}');
        print('========================');

        if (widget.onOpenDetail != null) {
          if (order.id != null && order.id!.isNotEmpty) {
            widget.onOpenDetail!.call(order.id!);
          } else {
            print('ERROR: Order ID is null or empty, cannot open detail page');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: Order ID tidak valid')),
            );
          }
        } else {
          if (order.id != null && order.id!.isNotEmpty) {
            // Try to use existing order data first, but fetch detail if needed
            print('=== NAVIGATING TO DETAIL PAGE ===');
            print('Passing order: $order');
            print('Passing orderId: ${order.id}');
            print('Order ID type: ${order.id.runtimeType}');
            print('Order ID is null: ${order.id == null}');
            print('Order ID is empty: ${order.id?.isEmpty ?? true}');
            print('Order ID length: ${order.id?.length}');
            print('=================================');

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TransactionDetailPage(
                  orderId: order.id, // Only pass orderId, fetch detail
                ),
              ),
            );
          } else {
            print('ERROR: Order ID is null or empty, cannot open detail page');
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
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 8),
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
            Text(
              // order.orderType ??
              "OrderType",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Text(
              order.paymentMethod?.toUpperCase() ?? "TUNAI",
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
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
          ],
        ),
      ),
    );
  }
}
