import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:xpress/presentation/home/dialogs/cash_success_dialog.dart';
import 'package:xpress/presentation/home/dialogs/discount_dialog.dart';
import 'package:xpress/presentation/home/dialogs/member_dialog.dart';
import 'package:xpress/presentation/home/dialogs/table_select_dialog.dart';
import 'package:xpress/presentation/home/dialogs/tax_dialog.dart';
import 'package:xpress/presentation/home/dialogs/service_dialog.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';
import 'package:xpress/presentation/home/dialogs/qris_confirm_dialog.dart';
import 'package:xpress/presentation/home/dialogs/qris_success_dialog.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';
import 'package:xpress/presentation/home/widgets/custom_button.dart';
import 'package:xpress/presentation/home/widgets/order_menu.dart';
import 'package:xpress/presentation/table/blocs/get_table/get_table_bloc.dart';
import '../../../core/components/components.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/presentation/home/models/order_model.dart';

class ConfirmPaymentPage extends StatefulWidget {
  final bool isTable;
  final TableModel? table;
  final String orderType; // dinein / takeaway
  final String orderNumber; // order number

  const ConfirmPaymentPage({
    super.key,
    required this.isTable,
    this.table,
    required this.orderType,
    required this.orderNumber,
  });

  @override
  State<ConfirmPaymentPage> createState() => _ConfirmPaymentPageState();
}

class _ConfirmPaymentPageState extends State<ConfirmPaymentPage> {
  final noteController = TextEditingController();
  final customerController = TextEditingController();
  final totalPayController = TextEditingController();
  bool isCash = true;
  int? _selectedTableNumber;
  String? _selectedMemberId;

  void _logPayment(String message) {
    assert(() {
      developer.log(message, name: 'ConfirmPaymentPage');
      return true;
    }());
  }

  // Helper method to parse table number from String to int
  int? _parseTableNumber(String? tableNumber) {
    if (tableNumber == null || tableNumber.isEmpty) return null;
    // Extract number from string like "T001" -> 1
    final numStr = tableNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(numStr);
  }

  @override
  void initState() {
    super.initState();
    _selectedTableNumber = _parseTableNumber(widget.table?.tableNumber);
    // Rebuild when total pay changes to update Pay button enabled state and change value
    totalPayController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    customerController.dispose();
    totalPayController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchMembers() async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members?per_page=100');
      final headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };
      var res = await http.get(uri, headers: headers);
      if (res.statusCode == 403) {
        res = await http.get(uri, headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Accept': 'application/json',
        });
      }
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body);
        List items = [];
        if (map is Map && map['data'] is List) items = map['data'];
        return items
            .where((e) =>
                e['is_active'] == true ||
                e['is_active'] == 1) // Filter only active members
            .map((e) => {
                  'id': e['id']?.toString(),
                  'name': e['name']?.toString() ?? '',
                  'member_number': e['member_number']?.toString() ?? '',
                  'phone': e['phone']?.toString() ?? '',
                  'email': e['email']?.toString() ?? '',
                })
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<Discount>> _fetchDiscounts() async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/discounts?per_page=100');
      final headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };
      var res = await http.get(uri, headers: headers);
      if (res.statusCode == 403) {
        res = await http.get(uri, headers: {
          'Authorization': 'Bearer ${auth.token}',
          'Accept': 'application/json',
        });
      }
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body);
        List items = [];
        if (map is Map && map['data'] is List) items = map['data'];
        return items
            .map((e) => Discount(
                  id: e['id'] is int ? e['id'] : int.tryParse('${e['id']}'),
                  name: e['name']?.toString(),
                  description: e['description']?.toString(),
                  type: (e['type'] ?? 'percentage').toString(),
                  value: (e['value'] ?? '0').toString(),
                ))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  // Submit order to server
  Future<bool> _submitOrder() async {
    try {
      _logPayment('========================================');
      _logPayment('SUBMIT ORDER: Starting...');

      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      _logPayment('SUBMIT ORDER: User ID = ${auth.user?.id}');
      _logPayment('SUBMIT ORDER: Store UUID = $storeUuid');
      _logPayment('SUBMIT ORDER: Table ID = ${widget.table?.id}');

      if (!mounted) return false;

      final state = context.read<CheckoutBloc>().state;

      final orderData = await state.maybeWhen(
        loaded: (
          products,
          discountModel,
          discount,
          discountAmount,
          tax,
          serviceCharge,
          totalQuantity,
          totalPrice,
          draftName,
          orderType,
        ) async {
          // Calculate amounts
          final subtotal = products.map((e) {
            final basePrice = e.product.price?.toIntegerFromText ?? 0;
            final variantPrice =
                e.variants?.fold<int>(0, (sum, v) => sum + v.priceAdjustment) ??
                    0;
            return (basePrice + variantPrice) * e.quantity;
          }).fold(0, (a, b) => a + b);

          final discAmt = _computeDiscountAmount(subtotal, discountModel);
          final taxAmt = _computeTaxAmount(subtotal, tax);
          final serviceAmt = _computeServiceAmount(subtotal, serviceCharge);

          // Debug print untuk melihat nilai diskon
          _logPayment('=== DEBUG DISCOUNT ===');
          _logPayment('Subtotal: $subtotal');
          _logPayment('Discount Model: $discountModel');
          _logPayment('Discount Amount: $discAmt');
          _logPayment('Tax Amount: $taxAmt');
          _logPayment('Service Amount: $serviceAmt');
          _logPayment('====================');

          final rawOrderType = orderType ?? widget.orderType;
          final operationMode = normalizeOperationMode(rawOrderType);
          _logPayment('Order Type (raw): $rawOrderType');
          _logPayment('Operation Mode (normalized): $operationMode');

          // Build items array
          final items = products.map((p) {
            final item = <String, dynamic>{
              'product_id': p.product.productId ?? p.product.id,
              'quantity': p.quantity,
            };

            // Add product_options if variants exist and have IDs
            if (p.variants != null && p.variants!.isNotEmpty) {
              final variantIds = p.variants!
                  .where((v) => v.id != null && v.id!.isNotEmpty)
                  .map((v) => v.id!)
                  .toList();
              if (variantIds.isNotEmpty) {
                item['product_options'] = variantIds;
              }
            }

            // Add notes if any (currently not implemented in UI, but placeholder)
            // item['notes'] = 'Some notes';

            return item;
          }).toList();

          _logPayment('SUBMIT ORDER: Items = ${items.length}');
          for (var i = 0; i < items.length; i++) {
            _logPayment('  Item $i: ${jsonEncode(items[i])}');
          }

          // Build request body
          final body = <String, dynamic>{
            'user_id': auth.user?.id,
            'status': 'completed',
            'payment_method': isCash ? 'cash' : 'qris',
            'operation_mode': operationMode,
          };

          // Add store_id if available
          if (storeUuid != null && storeUuid.isNotEmpty) {
            body['store_id'] = storeUuid;
          }

          // Add table_id if available
          // Priority: selected table number > widget table id
          String? tableId;
          if (_selectedTableNumber != null) {
            // Find table by number from the table list
            final tableBloc = context.read<GetTableBloc>();
            final tableState = tableBloc.state;
            if (tableState.maybeWhen(
              success: (tables) {
                TableModel? selectedTable;
                try {
                  selectedTable = tables.firstWhere(
                    (t) =>
                        int.tryParse(t.tableNumber ?? '0') ==
                        _selectedTableNumber,
                  );
                } catch (e) {
                  selectedTable = null;
                }
                if (selectedTable != null) {
                  tableId = selectedTable.id;
                }
                return true;
              },
              orElse: () => false,
            )) {
              // tableId already set above
            }
          } else if (widget.table?.id != null && widget.table!.id!.isNotEmpty) {
            tableId = widget.table!.id;
          }

          if (tableId != null && tableId!.isNotEmpty) {
            body['table_id'] = tableId;
          }

          // Add member_id if customer is a member
          if (_selectedMemberId != null) {
            body['member_id'] = _selectedMemberId;
          }

          // Add financial details
          if (discAmt > 0) body['discount_amount'] = discAmt.toDouble();
          if (serviceAmt > 0) body['service_charge'] = serviceAmt.toDouble();
          if (taxAmt > 0) body['tax'] = taxAmt.toDouble();

          // Add notes if any
          if (noteController.text.isNotEmpty) {
            body['notes'] = noteController.text;
          }

          // Add items
          body['items'] = items;

          return body;
        },
        orElse: () => null,
      );

      if (orderData == null) {
        _logPayment('SUBMIT ORDER: Failed - no order data');
        return false;
      }

      _logPayment('SUBMIT ORDER: Request body = ${jsonEncode(orderData)}');

      // Make API request
      final uri =
          Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/orders');
      final headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      _logPayment('SUBMIT ORDER: POST $uri');

      var res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(orderData),
      );

      _logPayment('SUBMIT ORDER: Response status = ${res.statusCode}');
      _logPayment('SUBMIT ORDER: Response body = ${res.body}');

      if (res.statusCode == 403) {
        // Retry without store header if forbidden
        headers.remove('X-Store-Id');
        res = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(orderData),
        );
        _logPayment('SUBMIT ORDER: Retry response status = ${res.statusCode}');
        _logPayment('SUBMIT ORDER: Retry response body = ${res.body}');
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        _logPayment('SUBMIT ORDER: Success!');

        // Extract order_id from response
        final orderRemoteDatasource = OrderRemoteDatasource();
        final orderId = orderRemoteDatasource.extractOrderId(res.body);

        if (orderId != null && orderId.isNotEmpty) {
          _logPayment('SUBMIT ORDER: Order ID = $orderId');

          // Calculate total amount for payment
          if (!mounted) return false;
          final state = context.read<CheckoutBloc>().state;
          final total = state.maybeWhen(
            loaded: (
              products,
              discountModel,
              discount,
              discountAmount,
              tax,
              serviceCharge,
              totalQuantity,
              totalPrice,
              draftName,
              orderType,
            ) {
              final subtotal = products
                  .map((e) =>
                      (e.product.price?.toIntegerFromText ?? 0) * e.quantity)
                  .fold(0, (a, b) => a + b);
              final discAmt = _computeDiscountAmount(subtotal, discountModel);
              final taxAmt = _computeTaxAmount(subtotal, tax);
              final serviceAmt = _computeServiceAmount(subtotal, serviceCharge);
              return subtotal - discAmt + taxAmt + serviceAmt;
            },
            orElse: () => 0,
          );

          // Create payment
          final paymentMethod = isCash ? 'cash' : 'qris';
          final paymentNotes =
              'Pembayaran ${paymentMethod == 'cash' ? 'Tunai' : 'Qris'} Mandiri';

          _logPayment('SUBMIT ORDER: Creating payment...');
          _logPayment('SUBMIT ORDER: Payment Method = $paymentMethod');
          // Extract total_amount from API response instead of recalculating
          int apiTotal = 0;
          try {
            final decoded = jsonDecode(res.body);
            final orderData = decoded['data'];
            if (orderData != null && orderData['total_amount'] != null) {
              final totalStr = orderData['total_amount'].toString();
              apiTotal = (double.tryParse(totalStr) ?? 0.0).round();
              if (apiTotal > 0) {
                _logPayment('SUBMIT ORDER: Using API total amount = $apiTotal');
                _logPayment('SUBMIT ORDER: Calculated total = $total');
              }
            }
          } catch (e) {
            // Ignore error
          }

          // Use API total if available, otherwise use calculated total
          final finalAmount = apiTotal > 0 ? apiTotal : total;
          _logPayment('SUBMIT ORDER: Amount = $finalAmount');

          final paymentCreated = await orderRemoteDatasource.createPayment(
            orderId: orderId,
            paymentMethod: paymentMethod,
            amount: finalAmount,
            receivedAmount: finalAmount,
            notes: paymentNotes,
          );

          if (paymentCreated) {
            _logPayment('SUBMIT ORDER: Payment created successfully!');
          } else {
            _logPayment('SUBMIT ORDER: Failed to create payment');
            _logPayment('SUBMIT ORDER: Response body for debugging: ${res.body}');
          }
        } else {
          _logPayment('ERROR: Could not extract order_id from response');
          _logPayment('SUBMIT ORDER: Response body: ${res.body}');
          try {
            final decoded = jsonDecode(res.body);
            _logPayment('SUBMIT ORDER: Decoded response: $decoded');
            _logPayment(
                'SUBMIT ORDER: Response keys: ${decoded is Map ? decoded.keys.toList() : 'not a map'}');
          } catch (e) {
            _logPayment('SUBMIT ORDER: Error parsing response: $e');
          }
        }

        _logPayment('========================================');
        return true;
      }

      _logPayment('SUBMIT ORDER: Failed with status ${res.statusCode}');
      _logPayment('========================================');
      return false;
    } catch (e) {
      _logPayment('SUBMIT ORDER: Exception = $e');
      _logPayment('========================================');
      return false;
    }
  }

  int _currentTotalPay() {
    return totalPayController.text.toIntegerFromText;
  }

  void _addToTotalPay(int amount) {
    final current = _currentTotalPay();
    final updated = current + amount;
    totalPayController.text = updated.toString();
  }

  int _calculateDueTotal() {
    final state = context.read<CheckoutBloc>().state;
    return state.maybeWhen(
      loaded: (
        products,
        discountModel,
        discount,
        discountAmount,
        tax,
        serviceCharge,
        totalQuantity,
        totalPrice,
        draftName,
        orderType,
      ) {
        final subtotal = products
            .map((e) => (e.product.price?.toIntegerFromText ?? 0) * e.quantity)
            .fold(0, (a, b) => a + b);
        final discAmt = _computeDiscountAmount(subtotal, discountModel);
        final taxAmt = _computeTaxAmount(subtotal, tax);
        final serviceAmt = _computeServiceAmount(subtotal, serviceCharge);
        final total = subtotal - discAmt + taxAmt + serviceAmt;
        return total.ceil();
      },
      orElse: () => 0,
    );
  }

  int _calculateChange() {
    final paid = _currentTotalPay();
    final due = _calculateDueTotal();
    final change = paid - due;
    return change > 0 ? change : 0;
  }

  String get _orderTypeLabel {
    final label = operationModeLabel(widget.orderType);
    return label == '-' ? widget.orderType : label;
  }

  int _computeDiscountAmount(int subtotal, Discount? model) {
    if (model == null) return 0;

    // Parse value as double since it can be "50.00" or "3000.00"
    final val = double.tryParse(model.value ?? '0') ?? 0.0;
    final type = (model.type ?? '').toLowerCase();

    _logPayment('=== DEBUG DISCOUNT CALCULATION ===');
    _logPayment('Model: $model');
    _logPayment('Value: ${model.value}');
    _logPayment('Parsed Value: $val');
    _logPayment('Type: $type');
    _logPayment('Subtotal: $subtotal');

    int discountAmount = 0;

    if (type == 'percentage') {
      // Percentage discount: 50.00 means 50%
      discountAmount = (subtotal * (val / 100)).floor();
      _logPayment(
          'Percentage calculation: $subtotal * ($val / 100) = $discountAmount');
    } else if (type == 'fixed') {
      // Fixed amount discount: 3000.00 means 3000 rupiah
      discountAmount = val.toInt();
      _logPayment('Fixed amount: $discountAmount');
    } else {
      _logPayment('Unknown discount type: $type');
    }

    // Ensure discount doesn't exceed subtotal
    discountAmount = discountAmount.clamp(0, subtotal);
    _logPayment('Final discount amount: $discountAmount');
    _logPayment('================================');

    return discountAmount;
  }

  int _computeTaxAmount(int subtotal, int taxPercent) {
    if (taxPercent <= 0) return 0;
    return (subtotal * (taxPercent / 100)).floor();
  }

  int _computeServiceAmount(int subtotal, int servicePercent) {
    if (servicePercent <= 0) return 0;
    return (subtotal * (servicePercent / 100)).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.primaryLight,
      body: Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, right: 6.0),
        child: Row(
          children: [
            // ✅ Konten utama
            Expanded(
              child: Row(
                children: [
                  // Detail pesanan
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        child: _buildOrderDetail(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Detail transaksi
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Detail Transaksi
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: _buildTransactionDetail(),
                          ),
                          SizedBox(height: 6),
                          // Pembayaran
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Pembayaran",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SpaceHeight(12),

                                // 🔹 Tombol Tunai & QRIS
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        svgIcon: Assets.icons.cash,
                                        filled: isCash,
                                        label: "Tunai",
                                        onPressed: () {
                                          setState(() {
                                            isCash = true;
                                          });
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(8),
                                    Expanded(
                                      child: CustomButton(
                                        svgIcon: Assets.icons.qr,
                                        filled: !isCash,
                                        label: "QRIS",
                                        onPressed: () {
                                          setState(() {
                                            isCash = false;
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SpaceHeight(12),

                                // 🔹 TextField Total + Tombol Uang Pas
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 46,
                                        child: TextField(
                                          controller: totalPayController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: "Total Bayar",
                                            prefixIcon: Padding(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Assets.icons.payment.svg(
                                                colorFilter: ColorFilter.mode(
                                                  AppColors.greyLightActive,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors.grey,
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: BorderSide(
                                                color: AppColors.primary,
                                                width: 1.5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 46,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          final total = _calculateDueTotal();
                                          totalPayController.text =
                                              total.toString();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          side: const BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                          minimumSize: const Size(120, 46),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8),
                                              topLeft: Radius.circular(0),
                                              bottomLeft: Radius.circular(0),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          "Uang Pas",
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SpaceHeight(12),

                                // 🔹 Tombol nominal
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "500",
                                        onPressed: () {
                                          _addToTotalPay(500);
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(6),
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "1000",
                                        onPressed: () {
                                          _addToTotalPay(1000);
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(6),
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "5000",
                                        onPressed: () {
                                          _addToTotalPay(5000);
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(6),
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "50000",
                                        onPressed: () {
                                          _addToTotalPay(50000);
                                        },
                                      ),
                                    ),
                                    const SpaceWidth(6),
                                    Expanded(
                                      child: CustomButton(
                                        filled: false,
                                        label: "100000",
                                        onPressed: () {
                                          _addToTotalPay(100000);
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SpaceHeight(12),

                                // 🔹 Total Kembalian
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.greyLight,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Kembalian',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Builder(builder: (context) {
                                        final change = _calculateChange();
                                        return Text(
                                          change.currencyFormatRp,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        );
                                      })
                                    ],
                                  ),
                                ),

                                const SpaceHeight(32),

                                // 🔹 Action Buttons
                                Row(
                                  children: [
                                    Button.outlined(
                                      width: 64,
                                      height: 64,
                                      color: AppColors.primaryLight,
                                      borderColor: AppColors.primary,
                                      padding: EdgeInsets.zero,
                                      icon: Assets.icons.backArrow.svg(
                                        height: 24,
                                        width: 24,
                                        colorFilter: ColorFilter.mode(
                                          AppColors.primary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      onPressed: () {
                                        final checkoutBloc =
                                            context.read<CheckoutBloc>();
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BlocProvider.value(
                                              value: checkoutBloc,
                                              child: DashboardPage(
                                                initialIndex: 0,
                                                selectedTable: widget.table,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SpaceWidth(8),
                                    Expanded(
                                      child: Builder(builder: (context) {
                                        final dueTotal = _calculateDueTotal();
                                        final isEnabled =
                                            _currentTotalPay() >= dueTotal &&
                                                dueTotal > 0;
                                        return CustomButton(
                                          height: 64,
                                          filled: true,
                                          svgIcon: Assets.icons.cash,
                                          label: 'Bayar',
                                          disabled: !isEnabled,
                                          onPressed: () async {
                                            if (!isEnabled) return;
                                            final total = _calculateDueTotal();
                                            final change = _calculateChange();
                                            if (isCash) {
                                              await showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) =>
                                                    BlocProvider.value(
                                                  value: context
                                                      .read<CheckoutBloc>(),
                                                  child: CashSuccessDialog(
                                                    total: total,
                                                    change: change,
                                                    orderType: widget.orderType,
                                                    tableNumber:
                                                        _selectedTableNumber ??
                                                            _parseTableNumber(
                                                                widget.table
                                                                    ?.tableNumber),
                                                    orderNumber:
                                                        widget.orderNumber,
                                                    onSubmitOrder: _submitOrder,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              await showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) =>
                                                    QrisConfirmDialog(
                                                  total: total,
                                                  change: change,
                                                  orderType: widget.orderType,
                                                  tableNumber:
                                                      _parseTableNumber(widget
                                                          .table?.tableNumber),
                                                  onAccepted: () async {
                                                    await showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (_) =>
                                                          BlocProvider.value(
                                                        value: context.read<
                                                            CheckoutBloc>(),
                                                        child:
                                                            QrisSuccessDialog(
                                                          total: total,
                                                          change: change,
                                                          orderType:
                                                              widget.orderType,
                                                          tableNumber:
                                                              _selectedTableNumber ??
                                                                  _parseTableNumber(
                                                                      widget
                                                                          .table
                                                                          ?.tableNumber),
                                                          orderNumber: widget
                                                              .orderNumber,
                                                          onSubmitOrder:
                                                              _submitOrder,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Detail Pesanan
  Widget _buildOrderDetail() {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return state.maybeWhen(
          orElse: () => _emptyOrder(),
          loaded: (products, _, __, ___, ____, _____, ______, _______, ________,
              _________) {
            if (products.isEmpty) {
              return _emptyOrder();
            }
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Detail Pesanan',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              height: 37,
                              width: 72,
                              decoration: BoxDecoration(
                                color: AppColors.greyLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                  child: Text(
                                widget.orderNumber,
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              )),
                            ),
                            const SizedBox(width: 12),
                            IntrinsicWidth(
                              child: Container(
                                height: 37,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    _orderTypeLabel,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if ((_selectedTableNumber ??
                                    _parseTableNumber(
                                        widget.table?.tableNumber)) !=
                                null) ...[
                              const SizedBox(width: 12),
                              Container(
                                height: 37,
                                width: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.successLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.table?.name ??
                                        "Meja ${_selectedTableNumber ?? _parseTableNumber(widget.table?.tableNumber) ?? ''}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    CustomButton(
                      width: 175,
                      height: 52,
                      svgIcon: Assets.icons.bill,
                      label: "Ubah Pesanan",
                      onPressed: () {
                        final checkoutBloc = context.read<
                            CheckoutBloc>(); // ✅ simpan dulu sebelum navigate

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value:
                                  checkoutBloc, // ✅ aman, ga pakai context lama
                              child:
                                  DashboardPage(), // atau HomePage sesuai flow kamu
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
                const SpaceHeight(20),
                // 🔹 Header kolom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 4,
                        child: Text(
                          "Menu",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          "Quantity",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "Subtotal",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
                // const Divider(),

                // 🔹 List pesanan
                Expanded(
                  child: BlocBuilder<CheckoutBloc, CheckoutState>(
                    builder: (context, state) {
                      return state.maybeWhen(
                        orElse: () => _emptyOrder(),
                        loaded: (
                          products,
                          _,
                          __,
                          ___,
                          ____,
                          _____,
                          ______,
                          _______,
                          ________,
                          _________,
                        ) {
                          if (products.isEmpty) return _emptyOrder();

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: products.length + 1,
                            itemBuilder: (context, i) {
                              if (i < products.length) {
                                return OrderMenu(
                                  data: products[i],
                                );
                              } else {
                                // After the last product, show the "Detail Pesanan" section
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Detail Pesanan',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 130,
                                      width: double.infinity,
                                      child: TextFormField(
                                        controller: noteController,
                                        maxLines: 5,
                                        decoration: InputDecoration(
                                          alignLabelWithHint: true,
                                          hintText:
                                              "Tambahkan Catatan Pesanan Jika Perlu",
                                          hintStyle: const TextStyle(
                                            color: AppColors.grey,
                                            fontSize: 16,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(12),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: const BorderSide(
                                                color: AppColors.grey,
                                                width: 1),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            borderSide: const BorderSide(
                                                color: AppColors.primary,
                                                width: 1.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🔹 Detail Transaksi
  Widget _buildTransactionDetail() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detail Transaksi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SpaceHeight(16),

          // 🔹 Nama Customer dengan icon user
          TextFormField(
            controller: customerController,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Assets.icons.user.svg(
                  height: 24,
                  width: 24,
                  colorFilter:
                      ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
                ),
              ),
              hintText: "Nama Customer",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),

          const SpaceHeight(16),

          // 🔹 Tombol Membership & Nomor Meja
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.user,
                  filled: false,
                  label: "Membership",
                  onPressed: () async {
                    // fetch members from API
                    final members = await _fetchMembers();
                    if (!context.mounted) return;
                    final memberNames = members
                        .map((m) => m['name'] ?? '')
                        .cast<String>()
                        .toList();
                    final res = await showDialog<String>(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (_) => MemberDialog(
                        members: memberNames,
                        initial: customerController.text,
                      ),
                    );
                    if (!context.mounted) return;
                    if (res != null && res.isNotEmpty) {
                      // Find the selected member using a safer approach
                      Map<String, dynamic>? selectedMember;
                      try {
                        selectedMember = members.firstWhere(
                          (m) => m['name'] == res,
                        );
                      } catch (e) {
                        // If not found, selectedMember will remain null
                        selectedMember = null;
                      }

                      if (selectedMember != null && selectedMember.isNotEmpty) {
                        if (!mounted) return;
                        setState(() {
                          _selectedMemberId = selectedMember!['id'];
                          customerController.text = res;
                        });
                      }
                    }
                  },
                ),
              ),
              const SpaceWidth(8),
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.table,
                  filled: false,
                  label: "Nomor Meja",
                  onPressed: () async {
                    final bloc = context.read<GetTableBloc>();
                    bloc.add(const GetTableEvent.getTables());

                    final selected = await showDialog<int>(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (_) => TableSelectDialog(
                        initialTable: _selectedTableNumber ??
                            _parseTableNumber(widget.table?.tableNumber) ??
                            0,
                      ),
                    );
                    if (!mounted) return;
                    if (selected != null) {
                      setState(() => _selectedTableNumber = selected);
                    }
                  },
                ),
              ),
            ],
          ),

          const SpaceHeight(16),

          // 🔹 Tombol Diskon, Pajak, Layanan
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.percentange,
                  filled: false,
                  label: "Diskon",
                  onPressed: () async {
                    final checkoutBloc = context.read<CheckoutBloc>();
                    final discounts = await _fetchDiscounts();
                    final selected = await showDialog<Discount>(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (_) => DiscountDialog(discounts: discounts),
                    );
                    if (!context.mounted) return;
                    if (selected != null) {
                      checkoutBloc.add(CheckoutEvent.addDiscount(selected));
                    }
                  },
                ),
              ),
              const SpaceWidth(8),
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.task,
                  filled: false,
                  label: "Pajak",
                  onPressed: () async {
                    final checkoutBloc = context.read<CheckoutBloc>();
                    final selected = await showDialog<int>(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (_) => const TaxDialog(),
                    );
                    if (!context.mounted) return;
                    if (selected != null) {
                      checkoutBloc.add(CheckoutEvent.addTax(selected));
                    }
                  },
                ),
              ),
              const SpaceWidth(8),
              Expanded(
                child: CustomButton(
                  svgIcon: Assets.icons.paste,
                  filled: false,
                  label: "Layanan",
                  onPressed: () async {
                    final checkoutBloc = context.read<CheckoutBloc>();
                    final selected = await showDialog<int>(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (_) => const ServiceDialog(),
                    );
                    if (!context.mounted) return;
                    if (selected != null) {
                      checkoutBloc
                          .add(CheckoutEvent.addServiceCharge(selected));
                    }
                  },
                ),
              ),
            ],
          ),

          const SpaceHeight(16),

          // 🔹 Breakdown harga (dinamis)
          BlocBuilder<CheckoutBloc, CheckoutState>(
            builder: (context, state) {
              return state.maybeWhen(
                orElse: () {
                  // Calculate totals even in orElse state
                  final state = context.read<CheckoutBloc>().state;
                  return state.maybeWhen(
                    loaded: (products,
                        discountModel,
                        discount,
                        discountAmount,
                        tax,
                        serviceCharge,
                        totalQuantity,
                        totalPrice,
                        draftName,
                        orderType) {
                      final subtotal = products
                          .map((e) =>
                              (e.product.price?.toIntegerFromText ?? 0) *
                              e.quantity)
                          .fold(0, (a, b) => a + b);
                      final discAmt =
                          _computeDiscountAmount(subtotal, discountModel);
                      final taxAmt = _computeTaxAmount(subtotal, tax);
                      final serviceAmt =
                          _computeServiceAmount(subtotal, serviceCharge);
                      final total = subtotal - discAmt + taxAmt + serviceAmt;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _priceRow("Subtotal", subtotal.currencyFormatRp),
                          _priceRow("Diskon", "-${discAmt.currencyFormatRp}"),
                          _priceRow("Layanan", serviceAmt.currencyFormatRp),
                          _priceRow("Pajak", taxAmt.currencyFormatRp),
                          _totalPriceRow("Total", total.currencyFormatRp),
                        ],
                      );
                    },
                    orElse: () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _priceRow("Subtotal", "Rp0"),
                        _priceRow("Diskon", "-Rp0"),
                        _priceRow("Layanan", "Rp0"),
                        _priceRow("Pajak", "Rp0"),
                        _totalPriceRow("Total", "Rp0"),
                      ],
                    ),
                  );
                },
                loaded: (products,
                    discountModel,
                    discount,
                    discountAmount,
                    tax,
                    serviceCharge,
                    totalQuantity,
                    totalPrice,
                    draftName,
                    orderType) {
                  final subtotal = products
                      .map((e) =>
                          (e.product.price?.toIntegerFromText ?? 0) *
                          e.quantity)
                      .fold(0, (a, b) => a + b);
                  final discAmt =
                      _computeDiscountAmount(subtotal, discountModel);
                  final taxAmt = _computeTaxAmount(subtotal, tax);
                  final serviceAmt =
                      _computeServiceAmount(subtotal, serviceCharge);
                  final total = subtotal - discAmt + taxAmt + serviceAmt;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _priceRow("Subtotal", subtotal.currencyFormatRp),
                      _priceRow("Diskon", "-${discAmt.currencyFormatRp}"),
                      _priceRow("Layanan", serviceAmt.currencyFormatRp),
                      _priceRow("Pajak", taxAmt.currencyFormatRp),
                      const SizedBox(
                        height: 8,
                      ),
                      _totalPriceRow("Total", total.currencyFormatRp),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: AppColors.greyLight,
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalPriceRow(String label, String value) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.all(Radius.circular(4))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyOrder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.bill.svg(
            width: 120,
            height: 120,
            colorFilter: ColorFilter.mode(AppColors.grey, BlendMode.srcIn),
          ),
          const SpaceHeight(24),
          Column(
            children: [
              Text(
                "Silakan Pilih Tipe Order",
                style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                "Tambahkan Pesanan",
                style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
