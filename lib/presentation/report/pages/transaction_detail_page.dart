import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/components/buttons.dart';
import 'package:xpress/core/widgets/print_button.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/store_local_datasource.dart';
import 'package:xpress/data/dataoutputs/print_dataoutputs.dart';
import 'package:xpress/presentation/home/models/product_quantity.dart';
import 'package:xpress/data/models/response/product_response_model.dart'
    as product_model;
import 'package:intl/intl.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/core/utils/amount_parser.dart';

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
  int? _calculatedTaxAmount;

  void _logDebug(String message) {
    assert(() {
      developer.log(message, name: 'TransactionDetailPage');
      return true;
    }());
  }

  /// Calculate tax amount from subtotal and store tax rate
  /// If taxAmount from order is null or 0, calculate from store settings
  Future<void> _calculateTaxAmount() async {
    if (_order == null) {
      setState(() => _calculatedTaxAmount = 0);
      return;
    }

    // First, try to use taxAmount from order
    final taxAmountFromOrder = AmountParser.parse(_order!.taxAmount);
    if (taxAmountFromOrder > 0) {
      setState(() => _calculatedTaxAmount = taxAmountFromOrder);
      return;
    }

    // If taxAmount is 0 or null, calculate from store settings
    final subtotal = AmountParser.parse(_order!.subtotal);
    if (subtotal <= 0) {
      setState(() => _calculatedTaxAmount = 0);
      return;
    }

    try {
      final storeDatasource = StoreLocalDatasource();
      final store = await storeDatasource.getStoreDetail();
      final taxRate = store?.settings?.taxRate ?? 0.0;

      if (taxRate > 0) {
        final calculatedTax = (subtotal * (taxRate / 100)).floor();
        setState(() => _calculatedTaxAmount = calculatedTax);
      } else {
        setState(() => _calculatedTaxAmount = 0);
      }
    } catch (e) {
      _logDebug('Error calculating tax from store settings: $e');
      setState(() => _calculatedTaxAmount = 0);
    }
  }

  @override
  void initState() {
    super.initState();
    _logDebug('=== DEBUG TRANSACTION DETAIL INIT ===');
    _logDebug('widget.order: ${widget.order}');
    _logDebug('widget.orderId: ${widget.orderId}');
    _logDebug('widget.orderId type: ${widget.orderId.runtimeType}');
    _logDebug('widget.orderId is null: ${widget.orderId == null}');
    _logDebug('widget.orderId is empty: ${widget.orderId?.isEmpty ?? true}');
    _logDebug('widget.orderId length: ${widget.orderId?.length}');
    _logDebug('=====================================');

    if (widget.order != null) {
      _order = widget.order;
      _isLoading = false;

      // Calculate tax amount
      _calculateTaxAmount();

      // Check if we need to fetch more detailed data
      if (_order!.totalAmount == null ||
          _order!.totalAmount!.isEmpty ||
          _order!.user == null ||
          _order!.table == null ||
          _order!.items == null ||
          _order!.items!.isEmpty) {
        _logDebug('Order data incomplete, fetching detail...');
        if (widget.orderId != null) {
          _fetchOrderDetail();
        }
      } else {
        _logDebug('Order data complete, using existing data');
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
          // Calculate tax amount after order is loaded
          _calculateTaxAmount();
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
    _logDebug('=== DEBUG ORDER DETAIL ===');
    _logDebug('Order: $_order');
    if (_order != null) {
      _logDebug('Order ID: ${_order!.id}');
      _logDebug('Order Number: ${_order!.orderNumber}');
      _logDebug('Total Amount: ${_order!.totalAmount}');
      _logDebug('Subtotal: ${_order!.subtotal}');
      _logDebug('Tax Amount: ${_order!.taxAmount}');
      _logDebug('Discount Amount: ${_order!.discountAmount}');
      _logDebug('Service Charge: ${_order!.serviceCharge}');
      _logDebug('Payment Method (old): ${_order!.paymentMethod}');
      _logDebug('Status: ${_order!.status}');
      _logDebug('User (Kasir): ${_order!.user?.name}');
      _logDebug('Member (Konsumen): ${_order!.member?.name}');
      _logDebug('Table: ${_order!.table?.name}');
      _logDebug('Items: ${_order!.items?.length}');
      _logDebug('Payments: ${_order!.payments?.length}');
      if (_order!.payments != null && _order!.payments!.isNotEmpty) {
        _logDebug(
            'First Payment Method: ${_order!.payments!.first.paymentMethod}');
        _logDebug('First Payment Status: ${_order!.payments!.first.status}');
      }
      if (_order!.items != null) {
        for (var item in _order!.items!) {
          _logDebug(
              '  - ${item.productName}: ${item.quantity}x ${item.totalPrice}');
        }
      }
    }
    _logDebug('========================');

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
              icon: Assets.icons.backArrow.svg(
                colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                height: 48,
                width: 48,
              ),
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
              icon: Assets.icons.backArrow.svg(
                colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                height: 48,
                width: 48,
              ),
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
            icon: Assets.icons.backArrow.svg(
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
              height: 48,
              width: 48,
            ),
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
                      'Rp ${NumberFormat('#,###').format(AmountParser.parse(_order?.totalAmount))}',
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
              _rowSpaceBetween('Metode Pembayaran', _getPaymentMethod()),
              const SizedBox(height: 8),
              _rowSpaceBetween('Konsumen', _order?.member?.name ?? '-'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Kasir', _order?.user?.name ?? 'N/A'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Meja', _order?.table?.name ?? '-'),
              const SizedBox(height: 8),
              _rowSpaceBetween(
                  'Status Order', _formatOrderStatus(_order?.status)),
              const SizedBox(height: 8),
              _rowSpaceBetween('Status Pembayaran', _getPaymentStatus()),
              const SizedBox(height: 16),
              // Refund button (outlined danger) using shared Button
              Button.outlined(
                onPressed: () {},
                height: 48,
                borderRadius: 8,
                color: AppColors.dangerLight,
                borderColor: AppColors.danger,
                textColor: AppColors.danger,
                icon: Assets.icons.refund.svg(
                  colorFilter:
                      ColorFilter.mode(AppColors.danger, BlendMode.srcIn),
                  height: 20,
                  width: 20,
                ),
                label: 'Refund',
              ),
              const SizedBox(height: 8),
              // Print receipt button using PrintButton
              PrintButton(
                label: 'Cetak Struk',
                color: AppColors.primary,
                icon: Assets.icons.printer.svg(
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  height: 20,
                  width: 20,
                ),
                height: 48,
                onPrint: () async {
                  if (_order == null) {
                    throw Exception('Data order tidak tersedia');
                  }

                  // Convert OrderItem to ProductQuantity
                  final products = <ProductQuantity>[];
                  if (_order!.items != null) {
                    for (var item in _order!.items!) {
                      // Parse unitPrice using AmountParser for robust parsing
                      final unitPriceInt = AmountParser.parse(item.unitPrice);
                      final product = product_model.Product(
                        id: item.productId,
                        productId: item.productId,
                        name: item.productName ?? 'Unknown',
                        price: unitPriceInt
                            .toString(), // Use parsed integer as string
                      );
                      products.add(ProductQuantity(
                        product: product,
                        quantity: item.quantity ?? 0,
                      ));
                    }
                  }

                  // Get payment info - use AmountParser for robust parsing
                  final paymentMethod = _getPaymentMethod();
                  final paymentAmount = _order!.payments?.isNotEmpty == true
                      ? AmountParser.parse(_order!.payments!.first.amount)
                      : AmountParser.parse(_order!.totalAmount);
                  final totalPrice = AmountParser.parse(_order!.totalAmount);
                  final kembalian = paymentAmount - totalPrice;
                  // Use calculated tax amount if available, otherwise use from order
                  final tax = _calculatedTaxAmount ??
                      AmountParser.parse(_order!.taxAmount);
                  final discount = AmountParser.parse(_order!.discountAmount);
                  final subTotal = AmountParser.parse(_order!.subtotal);
                  final totalQty = _order!.items?.fold<int>(
                          0, (sum, item) => sum + (item.quantity ?? 0)) ??
                      0;
                  final serviceCharge =
                      AmountParser.parse(_order!.serviceCharge);

                  final sizeReceipt =
                      await AuthLocalDataSource().getSizeReceipt();
                  final paperSize = int.tryParse(sizeReceipt) != null
                      ? int.parse(sizeReceipt)
                      : 58;

                  // Get operation mode from order
                  final operationMode = _order!.operationMode ?? 'dine_in';

                  return await PrintDataoutputs.instance.printOrderV3(
                    products,
                    totalQty,
                    totalPrice,
                    paymentMethod == 'Tunai' ? 'Cash' : 'QRIS',
                    paymentAmount,
                    kembalian,
                    subTotal, // ✅ Parameter ke-7: subTotal
                    discount, // ✅ Parameter ke-8: discount
                    tax, // ✅ Parameter ke-9: pajak
                    serviceCharge,
                    _order!.user?.name ?? 'Kasir',
                    _order!.member?.name ?? _order!.table?.name ?? 'Customer',
                    paperSize,
                    operationMode: operationMode,
                  );
                },
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
                                'Rp ${NumberFormat('#,###').format(AmountParser.parse(item.totalPrice))}',
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
                  'Rp ${NumberFormat('#,###').format(AmountParser.parse(_order?.subtotal))}',
                  isBold: true),
              const SizedBox(height: 8),
              _rowSpaceBetween(
                'Pajak',
                _calculatedTaxAmount != null
                    ? 'Rp ${NumberFormat('#,###').format(_calculatedTaxAmount)}'
                    : 'Rp ${NumberFormat('#,###').format(AmountParser.parse(_order?.taxAmount))}',
              ),
              const SizedBox(height: 8),
              _rowSpaceBetween('Diskon',
                  '-Rp ${NumberFormat('#,###').format(AmountParser.parse(_order?.discountAmount))}'),
              const SizedBox(height: 8),
              _rowSpaceBetween('Service Charge',
                  'Rp ${NumberFormat('#,###').format(AmountParser.parse(_order?.serviceCharge))}'),
              const SizedBox(height: 10),
              Container(
                  height: 2, width: double.infinity, color: AppColors.primary),
              const SizedBox(height: 10),
              _rowSpaceBetween('Total Belanja',
                  'Rp ${NumberFormat('#,###').format(AmountParser.parse(_order?.totalAmount))}',
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

  String _getPaymentMethod() {
    _logDebug('=== Getting Payment Method ===');
    _logDebug('Order payments: ${_order?.payments}');
    _logDebug('Order payments length: ${_order?.payments?.length}');

    // Try to get from payments array first
    if (_order?.payments != null && _order!.payments!.isNotEmpty) {
      final paymentMethod = _order!.payments!.first.paymentMethod;
      _logDebug('Payment method from payments array: $paymentMethod');
      if (paymentMethod != null && paymentMethod.isNotEmpty) {
        return _formatPaymentMethod(paymentMethod);
      }
    }

    // Fallback to old payment_method field
    if (_order?.paymentMethod != null && _order!.paymentMethod!.isNotEmpty) {
      _logDebug('Payment method from order field: ${_order!.paymentMethod}');
      return _formatPaymentMethod(_order!.paymentMethod);
    }

    _logDebug('No payment method found, returning N/A');
    return 'N/A';
  }

  String _getPaymentStatus() {
    _logDebug('=== Getting Payment Status ===');

    // Try to get from payments array first
    if (_order?.payments != null && _order!.payments!.isNotEmpty) {
      final paymentStatus = _order!.payments!.first.status;
      _logDebug('Payment status from payments array: $paymentStatus');
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        return _formatPaymentStatus(paymentStatus);
      }
    }

    // Fallback to order status
    if (_order?.status != null && _order!.status!.isNotEmpty) {
      _logDebug('Payment status from order status: ${_order!.status}');
      return _formatPaymentStatus(_order!.status);
    }

    _logDebug('No payment status found, returning N/A');
    return 'N/A';
  }

  String _formatPaymentMethod(String? method) {
    if (method == null || method.isEmpty) return 'N/A';

    switch (method.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'qris':
        return 'QRIS';
      case 'debit':
        return 'Kartu Debit';
      case 'credit':
        return 'Kartu Kredit';
      case 'transfer':
        return 'Transfer Bank';
      case 'e-wallet':
      case 'ewallet':
        return 'E-Wallet';
      default:
        // Capitalize first letter
        return method[0].toUpperCase() + method.substring(1);
    }
  }

  String _formatOrderStatus(String? status) {
    if (status == null || status.isEmpty) return 'N/A';

    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      case 'failed':
        return 'Gagal';
      default:
        // Capitalize first letter
        return status[0].toUpperCase() + status.substring(1);
    }
  }

  String _formatPaymentStatus(String? status) {
    if (status == null || status.isEmpty) return 'N/A';

    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'processing':
        return 'Memproses Pembayaran';
      case 'completed':
      case 'paid':
        return 'Lunas';
      case 'partial':
        return 'Sebagian';
      case 'refunded':
        return 'Dikembalikan';
      case 'failed':
        return 'Gagal';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        // Capitalize first letter
        return status[0].toUpperCase() + status.substring(1);
    }
  }
}
