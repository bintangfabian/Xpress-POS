import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

class TransactionDetailPage extends StatefulWidget {
  final ItemOrder? order;
  final String? orderId;
  final VoidCallback? onBack;
  const TransactionDetailPage(
      {super.key, this.order, this.orderId, this.onBack});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  ItemOrder? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('=== DEBUG TRANSACTION DETAIL INIT ===');
    print('widget.order: ${widget.order}');
    print('widget.orderId: ${widget.orderId}');
    print('widget.orderId type: ${widget.orderId.runtimeType}');
    print('widget.orderId is null: ${widget.orderId == null}');
    print('widget.orderId is empty: ${widget.orderId?.isEmpty ?? true}');
    print('widget.orderId length: ${widget.orderId?.length}');
    print('=====================================');

    if (widget.order != null) {
      _order = widget.order;
      _isLoading = false;

      // Check if we need to fetch more detailed data
      if (_order!.totalAmount == null ||
          _order!.totalAmount!.isEmpty ||
          _order!.user == null ||
          _order!.table == null ||
          _order!.items == null ||
          _order!.items!.isEmpty) {
        print('Order data incomplete, fetching detail...');
        if (widget.orderId != null) {
          _fetchOrderDetail();
        }
      } else {
        print('Order data complete, using existing data');
      }
    } else if (widget.orderId != null) {
      _fetchOrderDetail();
    } else {
      _isLoading = false;
      _errorMessage = 'No order data provided';
    }
  }

  Future<void> _fetchOrderDetail() async {
    try {
      final result =
          await OrderRemoteDatasource().getOrderDetail(widget.orderId!);
      result.fold(
        (error) {
          setState(() {
            _errorMessage = error;
            _isLoading = false;
          });
        },
        (order) {
          setState(() {
            _order = order;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print untuk melihat data order
    print('=== DEBUG ORDER DETAIL ===');
    print('Order: $_order');
    if (_order != null) {
      print('Order ID: ${_order!.id}');
      print('Order Number: ${_order!.orderNumber}');
      print('Total Amount: ${_order!.totalAmount}');
      print('Subtotal: ${_order!.subtotal}');
      print('Tax Amount: ${_order!.taxAmount}');
      print('Discount Amount: ${_order!.discountAmount}');
      print('Service Charge: ${_order!.serviceCharge}');
      print('Payment Method: ${_order!.paymentMethod}');
      print('Status: ${_order!.status}');
      print('User: ${_order!.user?.name}');
      print('Table: ${_order!.table?.name}');
      print('Items: ${_order!.items?.length}');
      if (_order!.items != null) {
        for (var item in _order!.items!) {
          print(
              '  - ${item.productName}: ${item.quantity}x ${item.totalPrice}');
        }
      }
    }
    print('========================');

    if (_isLoading) {
      return Container(
        margin: EdgeInsets.only(top: 6, bottom: 6, right: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 92,
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            leading: IconButton(
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!.call();
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: Assets.icons.backArrow
                  .svg(color: AppColors.white, height: 48, width: 48),
            ),
            title: const Text(
              'Detail Transaksi',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading order details...'),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        margin: EdgeInsets.only(top: 6, bottom: 6, right: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 92,
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            leading: IconButton(
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!.call();
                } else {
                  Navigator.of(context).pop();
                }
              },
              icon: Assets.icons.backArrow
                  .svg(color: AppColors.white, height: 48, width: 48),
            ),
            title: const Text(
              'Detail Transaksi',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text('Error: $_errorMessage'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (widget.orderId != null) {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _fetchOrderDetail();
                    }
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 6, bottom: 6, right: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 92,
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          leading: IconButton(
            onPressed: () {
              if (widget.onBack != null) {
                widget.onBack!.call();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Assets.icons.backArrow
                .svg(color: AppColors.white, height: 48, width: 48),
          ),
          title: const Text(
            'Detail Transaksi',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Centered amount and transaction id
              Center(
                child: Column(
                  children: [
                    Text(
                      'Rp ${NumberFormat('#,###').format((double.tryParse(_order?.totalAmount ?? '0') ?? 0).toInt())}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ID Transaksi: ${_order?.orderNumber ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _rowSpaceBetween(
                  'Waktu dan Tanggal',
                  _order?.createdAt != null
                      ? () {
                          final wibTime =
                              TimezoneHelper.toWib(_order!.createdAt!);
                          final timeStr =
                              DateFormat('HH:mm:ss').format(wibTime);
                          final dateStr =
                              DateFormat('d MMMM yyyy').format(wibTime);
                          return '$timeStr - $dateStr';
                        }()
                      : 'N/A'),
              const SizedBox(height: 8),
              _rowSpaceBetween(
                  'Metode Pembayaran', _order?.paymentMethod ?? 'N/A'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Konsumen', _order?.user?.name ?? 'N/A'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Meja', _order?.table?.name ?? ''),
              const SizedBox(height: 8),
              _rowSpaceBetween('Status Pembayaran', _order?.status ?? 'N/A'),
              const SizedBox(height: 16),
              // Refund button (outlined danger) using shared Button
              Button.outlined(
                onPressed: () {},
                height: 48,
                borderRadius: 8,
                color: AppColors.dangerLight,
                borderColor: AppColors.danger,
                textColor: AppColors.danger,
                icon: Assets.icons.refund
                    .svg(color: AppColors.danger, height: 20, width: 20),
                label: 'Refund',
              ),
              const SizedBox(height: 8),
              // Print receipt button (outlined primary) using shared Button
              Button.outlined(
                onPressed: () {},
                height: 48,
                borderRadius: 8,
                color: AppColors.primaryLight,
                borderColor: AppColors.primary,
                textColor: AppColors.primary,
                icon: Assets.icons.printer
                    .svg(color: AppColors.primary, height: 20, width: 20),
                label: 'Cetak Struk',
              ),
              const SizedBox(height: 32),
              const Text(
                'Daftar Produk',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              // Daftar produk dari order
              if (_order?.items != null && _order!.items!.isNotEmpty) ...[
                for (var item in _order!.items!) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName ?? 'N/A',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        Row(
                          children: [
                            Text('${item.quantity ?? 0}x',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black)),
                            SizedBox(width: 12),
                            Text(
                                'Rp ${NumberFormat('#,###').format((double.tryParse(item.totalPrice ?? '0') ?? 0).toInt())}',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                Text(
                  'Tidak ada item',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                  height: 2, width: double.infinity, color: AppColors.primary),
              const SizedBox(height: 10),
              _rowSpaceBetween('Subtotal',
                  'Rp ${NumberFormat('#,###').format((double.tryParse(_order?.subtotal ?? '0') ?? 0).toInt())}',
                  isBold: true),
              const SizedBox(height: 8),
              _rowSpaceBetween('Pajak',
                  'Rp ${NumberFormat('#,###').format((double.tryParse(_order?.taxAmount ?? '0') ?? 0).toInt())}'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Diskon',
                  '-Rp ${NumberFormat('#,###').format((double.tryParse(_order?.discountAmount ?? '0') ?? 0).toInt())}'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Service Charge',
                  'Rp ${NumberFormat('#,###').format((double.tryParse(_order?.serviceCharge ?? '0') ?? 0).toInt())}'),
              const SizedBox(height: 10),
              Container(
                  height: 2, width: double.infinity, color: AppColors.primary),
              const SizedBox(height: 10),
              _rowSpaceBetween('Total Belanja',
                  'Rp ${NumberFormat('#,###').format((double.tryParse(_order?.totalAmount ?? '0') ?? 0).toInt())}',
                  isBold: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowSpaceBetween(String left, String right, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
