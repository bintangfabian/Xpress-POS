import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:xpress/presentation/home/dialogs/cash_success_dialog.dart';
import 'package:xpress/presentation/home/dialogs/discount_dialog.dart';
import 'package:xpress/presentation/home/dialogs/member_dialog.dart';
import 'package:xpress/presentation/home/dialogs/table_select_dialog.dart';
import 'package:xpress/presentation/home/dialogs/tax_dialog.dart';
import 'package:xpress/presentation/home/dialogs/service_dialog.dart';
import 'package:xpress/presentation/home/dialogs/qris_confirm_dialog.dart';
import 'package:xpress/presentation/home/dialogs/qris_success_dialog.dart';
import 'package:xpress/presentation/home/models/order_model.dart';
import 'package:xpress/presentation/home/models/product_quantity.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';
import 'package:xpress/presentation/home/widgets/custom_button.dart';
import 'package:xpress/presentation/home/widgets/order_menu.dart';
import 'package:xpress/presentation/table/blocs/get_table/get_table_bloc.dart';
import '../../../core/components/components.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/repositories/order_repository.dart';
import 'package:xpress/data/datasources/local/database/database.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';
import 'package:xpress/core/utils/amount_parser.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/models/response/discount_response_model.dart'
    as discount_model;

class _CheckoutAmounts {
  final int subtotal;
  final int discount;
  final int tax;
  final int service;
  final int total;

  const _CheckoutAmounts({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.service,
    required this.total,
  });
}

class _OrderSubmissionData {
  final Map<String, dynamic> body;
  final _CheckoutAmounts amounts;

  const _OrderSubmissionData({
    required this.body,
    required this.amounts,
  });
}

class ConfirmPaymentPage extends StatefulWidget {
  final bool isTable;
  final TableModel? table;
  final String orderType; // dinein / takeaway
  final String orderNumber; // order number
  final String? existingOrderId;
  final ItemOrder? openBillOrder;

  const ConfirmPaymentPage({
    super.key,
    required this.isTable,
    this.table,
    required this.orderType,
    required this.orderNumber,
    this.existingOrderId,
    this.openBillOrder,
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

  bool get _isOpenBillPayment => widget.existingOrderId != null;
  ItemOrder? get _openBill => widget.openBillOrder;

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
    _selectedMemberId = _openBill?.member?.id;
    if (_openBill?.notes != null && _openBill!.notes!.isNotEmpty) {
      noteController.text = _openBill!.notes!;
    }
    // Rebuild when total pay changes to update Pay button enabled state and change value
    totalPayController.addListener(() {
      if (mounted) setState(() {});
    });
    if (_isOpenBillPayment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final due = _calculateDueTotal();
        if (due > 0 && totalPayController.text.toIntegerFromText == 0) {
          totalPayController.text = due.toString();
        }
      });
    }
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

  Future<List<discount_model.Discount>> _fetchDiscounts() async {
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
            .map((e) => discount_model.Discount(
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

  // Submit order to server (2-step flow: draft order → payment)
  // ✅ FIX: Save to local database first, then sync if online
  Future<bool> _submitOrder() async {
    try {
      print('========================================');
      print('🚀 Starting 2-step payment flow...');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final onlineCheckerBloc = context.read<OnlineCheckerBloc>();
      final isOnline = onlineCheckerBloc.isOnline;

      final submissionData = await _prepareOrderSubmissionData(
        userId: auth.user?.id,
        storeUuid: storeUuid,
      );

      if (submissionData == null) {
        print('❌ Failed to prepare submission data');
        return false;
      }

      // ✅ STEP 1: ALWAYS save to local database first
      print('💾 Step 1: Saving order to local database...');
      final checkoutState = context.read<CheckoutBloc>().state;
      final orderRepository = OrderRepository(database: AppDatabase.instance);

      OrderModel? localOrderModel;
      String? localOrderUuid;

      await checkoutState.maybeWhen(
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
          final amounts =
              _resolveAmounts(products, discountModel, tax, serviceCharge);

          localOrderModel = OrderModel(
            paymentAmount: _currentTotalPay(),
            subTotal: amounts.subtotal,
            tax: amounts.tax,
            discount: discountAmount,
            discountAmount: amounts.discount,
            serviceCharge: amounts.service,
            total: amounts.total,
            paymentMethod: isCash ? 'cash' : 'qris',
            totalItem: totalQuantity,
            idKasir: auth.user?.id ?? 1,
            namaKasir: auth.user?.name ?? 'Kasir A',
            transactionTime: TimezoneHelper.now().toIso8601String(),
            customerName: customerController.text,
            tableNumber: _selectedTableNumber ??
                _parseTableNumber(widget.table?.tableNumber) ??
                0,
            status: 'completed',
            paymentStatus: 'paid',
            isSync: isOnline ? 1 : 0,
            operationMode:
                normalizeOperationMode(orderType ?? widget.orderType),
            orderItems: products,
          );

          localOrderUuid =
              await orderRepository.createOrderLocal(localOrderModel!);
          print('✅ Order saved locally (UUID: $localOrderUuid)');
        },
        orElse: () async {
          print('⚠️ No checkout state available');
        },
      );

      if (localOrderModel == null || localOrderUuid == null) {
        print('❌ Failed to save order locally');
        return false;
      }

      // ✅ STEP 2: Try to sync to server if online
      if (isOnline) {
        print('🌐 Step 2: Attempting to sync to server...');
        final orderRemoteDatasource = OrderRemoteDatasource();

        if (_isOpenBillPayment && widget.existingOrderId != null) {
          final orderId = widget.existingOrderId!;
          final payload = Map<String, dynamic>.from(submissionData.body);

          print('💳 Open Bill Payment (2-Step Flow)...');

          // ✅ Save to local database first
          if (localOrderModel != null && localOrderUuid != null) {
            print(
                '✅ Open bill order already saved locally (UUID: $localOrderUuid)');
          }

          // Step 1: Update order to open status (if online)
          if (isOnline) {
            print('📝 Step 2: Updating open bill order (set to open)...');
            payload['payment_mode'] = 'open_bill';
            payload['status'] =
                'open'; // ✅ Set to open - payment will complete it
            payload['subtotal'] = submissionData.amounts.subtotal;
            payload['total_amount'] = submissionData.amounts.total;
            payload['discount_amount'] =
                submissionData.amounts.discount.toDouble();
            payload['service_charge'] =
                submissionData.amounts.service.toDouble();
            payload['tax'] = submissionData.amounts.tax.toDouble();
            payload['skip_inventory_deduction'] =
                true; // ✅ Skip deduct stok saat bayar (sudah di-deduct saat create open bill)
            if (widget.orderNumber.isNotEmpty) {
              payload['order_number'] = widget.orderNumber;
            }

            final updateResult =
                await orderRemoteDatasource.updateOpenBillOrder(
              orderId: orderId,
              orderData: payload,
            );

            return await updateResult.fold(
              (error) async {
                print('❌ ERROR updating open bill: $error');
                print('✅ Order saved locally, will sync when online');
                return true; // ✅ Return true because order saved locally
              },
              (_) async {
                print('✅ Open bill order updated (status: open)');

                // Step 2: Create payment (will auto-complete order & trigger loyalty)
                print('💰 Step 3: Creating payment...');
                final paymentMethod = isCash ? 'cash' : 'qris';
                final paymentNotes =
                    'Pembayaran ${paymentMethod == 'cash' ? 'Tunai' : 'Qris'} Mandiri';

                final receivedAmount = _currentTotalPay();
                final dueAmount = submissionData.amounts.total;

                print('   Order ID: $orderId');
                print('   Payment Method: $paymentMethod');
                print('   Amount: $dueAmount');
                print('   Received: $receivedAmount');

                // ✅ Create payment → Backend auto-completes order → Loyalty points added
                final paymentCreated =
                    await orderRemoteDatasource.createPayment(
                  orderId: orderId,
                  paymentMethod: paymentMethod,
                  amount: dueAmount,
                  receivedAmount:
                      receivedAmount > 0 ? receivedAmount : dueAmount,
                  notes: paymentNotes,
                );

                if (paymentCreated && localOrderUuid != null) {
                  await orderRepository.markAsSynced(localOrderUuid!,
                      serverId: orderId);
                  print('✅ Payment created! Order auto-completed by backend.');
                  print(
                      '⭐ Loyalty points automatically added via OrderObserver');

                  // Show points earned notification if member selected
                  if (_selectedMemberId != null &&
                      _selectedMemberId!.isNotEmpty) {
                    _showPointsEarnedNotification(dueAmount);
                  }
                } else {
                  print(
                      '❌ WARNING: Failed to create payment, but order saved locally');
                }

                return true; // ✅ Always return true (order saved locally)
              },
            );
          } else {
            print(
                '📴 Offline: Open bill order saved locally, will sync when online');
            return true; // ✅ Return true when offline
          }
        } else {
          // Regular Order (2-Step Flow) - if not open bill payment
          print('📦 Regular Order Payment (2-Step Flow)...');

          // Step 2: Create open order (if online)
          if (isOnline) {
            print('📝 Step 2: Creating open order on server...');
            final uri = Uri.parse(
                '${Variables.baseUrl}/api/${Variables.apiVersion}/orders');
            final headers = {
              'Authorization': 'Bearer ${auth.token}',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (storeUuid != null && storeUuid.isNotEmpty)
                'X-Store-Id': storeUuid,
            };

            print('   Payload status: ${submissionData.body['status']}');
            print(
                '   Items count: ${submissionData.body['items']?.length ?? 0}');

            try {
              var res = await http.post(
                uri,
                headers: headers,
                body: jsonEncode(submissionData.body),
              );

              if (res.statusCode == 403) {
                print('   Got 403, retrying without X-Store-Id...');
                headers.remove('X-Store-Id');
                res = await http.post(
                  uri,
                  headers: headers,
                  body: jsonEncode(submissionData.body),
                );
              }

              if (res.statusCode == 200 || res.statusCode == 201) {
                final orderId = orderRemoteDatasource.extractOrderId(res.body);

                if (orderId != null && orderId.isNotEmpty) {
                  print('✅ Open order created (ID: $orderId)');

                  // Step 3: Create payment (will auto-complete order & trigger loyalty)
                  print('💰 Step 3: Creating payment...');
                  final paymentMethod = isCash ? 'cash' : 'qris';
                  final paymentNotes =
                      'Pembayaran ${paymentMethod == 'cash' ? 'Tunai' : 'Qris'} Mandiri';

                  int apiTotal = 0;
                  try {
                    final decoded = jsonDecode(res.body);
                    final data = decoded['data'];
                    if (data != null && data['total_amount'] != null) {
                      apiTotal =
                          (double.tryParse(data['total_amount'].toString()) ??
                                  0.0)
                              .round();
                    }
                  } catch (_) {}

                  final finalAmount =
                      apiTotal > 0 ? apiTotal : submissionData.amounts.total;

                  final receivedAmount = _currentTotalPay();

                  print('   Order ID: $orderId');
                  print('   Payment Method: $paymentMethod');
                  print('   Amount: $finalAmount');
                  print('   Received: $receivedAmount');

                  // ✅ Create payment → Backend auto-completes order → Loyalty points added
                  final paymentCreated =
                      await orderRemoteDatasource.createPayment(
                    orderId: orderId,
                    paymentMethod: paymentMethod,
                    amount: finalAmount,
                    receivedAmount:
                        receivedAmount > 0 ? receivedAmount : finalAmount,
                    notes: paymentNotes,
                  );

                  if (paymentCreated && localOrderUuid != null) {
                    await orderRepository.markAsSynced(localOrderUuid!,
                        serverId: orderId);
                    print(
                        '✅ Payment created! Order auto-completed by backend.');
                    print(
                        '⭐ Loyalty points automatically added via OrderObserver');

                    // Show points earned notification if member selected
                    if (_selectedMemberId != null &&
                        _selectedMemberId!.isNotEmpty) {
                      _showPointsEarnedNotification(finalAmount);
                    }
                  } else {
                    print(
                        '❌ WARNING: Failed to create payment, but order saved locally');
                  }

                  return true; // ✅ Always return true (order saved locally)
                }

                return true; // ✅ Order saved locally even if server response is unexpected
              }

              print('⚠️ Server request failed, but order saved locally');
              return true; // ✅ Return true because order is saved locally
            } catch (e) {
              print('❌ Error during server sync: $e');
              print('✅ Order saved locally despite error');
              return true; // ✅ Return true because order is saved locally
            }
          } else {
            print(
                '📴 Offline mode: Order saved locally, will sync when online');
            return true; // ✅ Always return true when offline (order saved locally)
          }
        }
      } else {
        // Offline mode - order already saved locally
        print('📴 Offline mode: Order saved locally, will sync when online');
        return true; // ✅ Always return true when offline (order saved locally)
      }
    } catch (e) {
      print('❌ Error during order submission: $e');
      print('✅ Order saved locally despite error');
      return true; // ✅ Return true because order is saved locally
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
    final amounts = _computeCheckoutAmounts();
    return amounts.total;
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

  int _computeDiscountAmount(int subtotal, discount_model.Discount? model) {
    if (model == null) return 0;

    // Parse value as double since it can be "50.00" or "3000.00"
    final val = double.tryParse(model.value ?? '0') ?? 0.0;
    final type = (model.type ?? '').toLowerCase();

    // print('=== DEBUG DISCOUNT CALCULATION ===');
    // print('Model: $model');
    // print('Value: ${model.value}');
    // print('Parsed Value: $val');
    // print('Type: $type');
    // print('Subtotal: $subtotal');

    int discountAmount = 0;

    if (type == 'percentage') {
      // Percentage discount: 50.00 means 50%
      discountAmount = (subtotal * (val / 100)).floor();
      // print('Percentage calculation: $subtotal * ($val / 100) = $discountAmount');
    } else if (type == 'fixed') {
      // Fixed amount discount: 3000.00 means 3000 rupiah
      discountAmount = val.toInt();
      // print('Fixed amount: $discountAmount');
    } else {
      // print('Unknown discount type: $type');
    }

    // Ensure discount doesn't exceed subtotal
    discountAmount = discountAmount.clamp(0, subtotal);
    // print('Final discount amount: $discountAmount');
    // print('================================');

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

  int _parseAmount(String? raw) => AmountParser.parse(raw);

  _CheckoutAmounts _resolveAmounts(
    List<ProductQuantity> products,
    discount_model.Discount? discountModel,
    int taxPercent,
    int servicePercent,
  ) {
    int subtotal = products.map((e) {
      final basePrice = e.product.price?.toIntegerFromText ?? 0;
      final variantPrice =
          e.variants?.fold<int>(0, (sum, v) => sum + v.priceAdjustment) ?? 0;
      return (basePrice + variantPrice) * e.quantity;
    }).fold(0, (a, b) => a + b);

    if (subtotal <= 0 && _isOpenBillPayment) {
      subtotal = _parseAmount(_openBill?.subtotal);
      if (subtotal <= 0 && (_openBill?.items?.isNotEmpty ?? false)) {
        subtotal = _openBill!.items!.fold<int>(
          0,
          (sum, item) => sum + _parseAmount(item.totalPrice),
        );
      }
    }

    int discountAmount = _computeDiscountAmount(subtotal, discountModel);
    if (discountAmount <= 0 && _isOpenBillPayment) {
      discountAmount = _parseAmount(_openBill?.discountAmount);
      if (discountAmount > subtotal) {
        discountAmount = subtotal;
      }
    }

    int taxAmount = _computeTaxAmount(subtotal, taxPercent);
    if (taxAmount <= 0 && _isOpenBillPayment) {
      taxAmount = _parseAmount(_openBill?.taxAmount);
    }

    int serviceAmount = _computeServiceAmount(subtotal, servicePercent);
    if (serviceAmount <= 0 && _isOpenBillPayment) {
      serviceAmount = _parseAmount(_openBill?.serviceCharge);
    }

    int total = subtotal - discountAmount + taxAmount + serviceAmount;
    if (total <= 0 && _isOpenBillPayment) {
      total = _parseAmount(_openBill?.totalAmount);
    }
    if (total < 0) total = 0;

    return _CheckoutAmounts(
      subtotal: subtotal,
      discount: discountAmount,
      tax: taxAmount,
      service: serviceAmount,
      total: total,
    );
  }

  _CheckoutAmounts _computeCheckoutAmounts() {
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
      ) =>
          _resolveAmounts(products, discountModel, tax, serviceCharge),
      orElse: () => _resolveAmounts(const [], null, 0, 0),
    );
  }

  // Helper: Show loyalty points earned notification
  void _showPointsEarnedNotification(int amount) {
    // Calculate points (1 point per Rp 1.000)
    final pointsEarned = (amount / 1000).floor();

    if (pointsEarned > 0 && mounted) {
      print('🎉 Member earned $pointsEarned loyalty points!');

      // Show snackbar notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber),
              const SizedBox(width: 12),
              Text(
                '⭐ Earned $pointsEarned loyalty points!',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<_OrderSubmissionData?> _prepareOrderSubmissionData({
    required int? userId,
    required String? storeUuid,
  }) async {
    if (!mounted) return null;

    // ✅ FIX: For open bill payment, use data from openBillOrder instead of checkout state
    if (_isOpenBillPayment && _openBill != null) {
      print('📦 Preparing open bill payment submission data...');
      final openBill = _openBill!;
      print('   Open Bill ID: ${openBill.id}');
      print('   Order Number: ${openBill.orderNumber}');
      print('   Items count: ${openBill.items?.length ?? 0}');

      final subtotal = AmountParser.parse(openBill.subtotal);
      final discountAmount = AmountParser.parse(openBill.discountAmount);
      final taxAmount = AmountParser.parse(openBill.taxAmount);
      final serviceAmount = AmountParser.parse(openBill.serviceCharge);
      final total = AmountParser.parse(openBill.totalAmount);

      print('   Subtotal: $subtotal');
      print('   Discount: $discountAmount');
      print('   Tax: $taxAmount');
      print('   Service: $serviceAmount');
      print('   Total: $total');

      final amounts = _CheckoutAmounts(
        subtotal: subtotal,
        discount: discountAmount,
        tax: taxAmount,
        service: serviceAmount,
        total: total,
      );

      final items = (openBill.items ?? []).map((item) {
        // ✅ FIX: Server requires unit_price and total_price for each item
        final unitPrice = AmountParser.parse(item.unitPrice);
        final totalPrice = AmountParser.parse(item.totalPrice);
        final quantity = item.quantity ?? 1;

        print(
            '   - Item: ${item.productName} (ID: ${item.productId}) x$quantity');
        print('     Unit Price: $unitPrice, Total: $totalPrice');

        // ✅ Validate that we have required data
        if (item.productId == null || unitPrice == 0) {
          print('     ⚠️ WARNING: Missing product_id or unit_price');
        }

        return <String, dynamic>{
          'product_id': item.productId,
          'product_name': item.productName ?? '',
          'quantity': quantity,
          'unit_price': unitPrice,
          'total_price': totalPrice > 0 ? totalPrice : (unitPrice * quantity),
        };
      }).toList();

      if (items.isEmpty) {
        print('❌ ERROR: No items in open bill!');
        return null;
      }

      print('   Total items prepared: ${items.length}');

      final operationMode =
          normalizeOperationMode(openBill.operationMode ?? widget.orderType);

      final body = <String, dynamic>{
        'user_id': userId,
        'status': 'completed',
        'payment_method': isCash ? 'cash' : 'qris',
        'operation_mode': operationMode,
        'items': items,
      };

      if (storeUuid != null && storeUuid.isNotEmpty) {
        body['store_id'] = storeUuid;
      }

      if (openBill.table?.id != null && openBill.table!.id!.isNotEmpty) {
        body['table_id'] = openBill.table!.id;
      }

      if (_selectedMemberId != null && _selectedMemberId!.isNotEmpty) {
        body['member_id'] = _selectedMemberId;
      }

      if (noteController.text.isNotEmpty) {
        body['notes'] = noteController.text;
      }

      if (amounts.discount > 0) {
        body['discount_amount'] = amounts.discount.toDouble();
      }
      if (amounts.service > 0) {
        body['service_charge'] = amounts.service.toDouble();
      }
      if (amounts.tax > 0) {
        body['tax'] = amounts.tax.toDouble();
      }

      if (widget.orderNumber.isNotEmpty) {
        body['order_number'] = widget.orderNumber;
      }

      print('✅ Open bill submission data prepared successfully');
      print('========================================');
      return _OrderSubmissionData(body: body, amounts: amounts);
    }

    // Normal order flow
    final state = context.read<CheckoutBloc>().state;

    return await state.maybeWhen(
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
        final amounts =
            _resolveAmounts(products, discountModel, tax, serviceCharge);

        final rawOrderType = orderType ?? widget.orderType;
        final operationMode = normalizeOperationMode(rawOrderType);

        final items = products.map((p) {
          final item = <String, dynamic>{
            'product_id': p.product.productId ?? p.product.id,
            'quantity': p.quantity,
          };

          if (p.variants != null && p.variants!.isNotEmpty) {
            final variantIds = p.variants!
                .where((v) => v.id != null && v.id!.isNotEmpty)
                .map((v) => v.id!)
                .toList();
            if (variantIds.isNotEmpty) {
              item['product_options'] = variantIds;
            }
          }

          return item;
        }).toList();

        final body = <String, dynamic>{
          'user_id': userId,
          'status': 'open', // ✅ Start as open - payment will complete it
          'payment_method': isCash ? 'cash' : 'qris',
          'operation_mode': operationMode,
          'items': items,
        };

        if (storeUuid != null && storeUuid.isNotEmpty) {
          body['store_id'] = storeUuid;
        }

        String? tableId;
        if (_selectedTableNumber != null) {
          final tableState = context.read<GetTableBloc>().state;
          tableState.maybeWhen(
            success: (tables) {
              try {
                tableId = tables
                    .firstWhere(
                      (t) =>
                          int.tryParse(t.tableNumber ?? '0') ==
                          _selectedTableNumber,
                    )
                    .id;
              } catch (_) {
                tableId = null;
              }
              return true;
            },
            orElse: () => false,
          );
        } else if (widget.table?.id != null && widget.table!.id!.isNotEmpty) {
          tableId = widget.table!.id;
        }

        if (tableId != null && tableId!.isNotEmpty) {
          body['table_id'] = tableId;
        }

        if (_selectedMemberId != null && _selectedMemberId!.isNotEmpty) {
          body['member_id'] = _selectedMemberId;
        }

        if (noteController.text.isNotEmpty) {
          body['notes'] = noteController.text;
        }

        if (amounts.discount > 0 || _isOpenBillPayment) {
          body['discount_amount'] = amounts.discount.toDouble();
        }
        if (amounts.service > 0 || _isOpenBillPayment) {
          body['service_charge'] = amounts.service.toDouble();
        }
        if (amounts.tax > 0 || _isOpenBillPayment) {
          body['tax'] = amounts.tax.toDouble();
        }

        if (_isOpenBillPayment && widget.orderNumber.isNotEmpty) {
          body['order_number'] = widget.orderNumber;
        }

        return _OrderSubmissionData(body: body, amounts: amounts);
      },
      orElse: () => null,
    );
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
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                          AppColors
                                                              .greyLightActive,
                                                          BlendMode.srcIn)),
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
                                          colorFilter: const ColorFilter.mode(
                                              AppColors.primary,
                                              BlendMode.srcIn),
                                          height: 24,
                                          width: 24),
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: const Text(
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
                    colorFilter: const ColorFilter.mode(
                        AppColors.grey, BlendMode.srcIn)),
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
                    final memberNames = members
                        .map((m) => m['name'] ?? '')
                        .cast<String>()
                        .toList();
                    if (!mounted) return;
                    final res = await showDialog<String>(
                      context: context,
                      builder: (_) => MemberDialog(
                        members: memberNames,
                        initial: customerController.text,
                      ),
                    );
                    if (!mounted) return;
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

                    if (!mounted) return;
                    final selected = await showDialog<int>(
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
                    final discounts = await _fetchDiscounts();
                    if (!mounted) return;
                    final selected = await showDialog<discount_model.Discount>(
                      context: context,
                      builder: (_) => DiscountDialog(discounts: discounts),
                    );
                    if (!mounted) return;
                    if (selected != null) {
                      context
                          .read<CheckoutBloc>()
                          .add(CheckoutEvent.addDiscount(selected));
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
                    if (!mounted) return;
                    final selected = await showDialog<int>(
                      context: context,
                      builder: (_) => const TaxDialog(),
                    );
                    if (!mounted) return;
                    if (selected != null) {
                      context
                          .read<CheckoutBloc>()
                          .add(CheckoutEvent.addTax(selected));
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
                    if (!mounted) return;
                    final selected = await showDialog<int>(
                      context: context,
                      builder: (_) => const ServiceDialog(),
                    );
                    if (!mounted) return;
                    if (selected != null) {
                      context
                          .read<CheckoutBloc>()
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
                  final amounts = _computeCheckoutAmounts();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _priceRow("Subtotal", amounts.subtotal.currencyFormatRp),
                      _priceRow(
                          "Diskon", "-${amounts.discount.currencyFormatRp}"),
                      _priceRow("Layanan", amounts.service.currencyFormatRp),
                      _priceRow("Pajak", amounts.tax.currencyFormatRp),
                      _totalPriceRow("Total", amounts.total.currencyFormatRp),
                    ],
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
                  final amounts = _resolveAmounts(
                      products, discountModel, tax, serviceCharge);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _priceRow("Subtotal", amounts.subtotal.currencyFormatRp),
                      _priceRow(
                          "Diskon", "-${amounts.discount.currencyFormatRp}"),
                      _priceRow("Layanan", amounts.service.currencyFormatRp),
                      _priceRow("Pajak", amounts.tax.currencyFormatRp),
                      const SizedBox(
                        height: 8,
                      ),
                      _totalPriceRow("Total", amounts.total.currencyFormatRp),
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
              colorFilter:
                  const ColorFilter.mode(AppColors.grey, BlendMode.srcIn)),
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
