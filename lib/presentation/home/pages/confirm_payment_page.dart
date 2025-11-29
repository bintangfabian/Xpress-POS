import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/core/extensions/int_ext.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/core/extensions/build_context_ext.dart';
import 'package:xpress/data/datasources/store_local_datasource.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:xpress/presentation/home/dialogs/cash_success_dialog.dart';
import 'package:xpress/presentation/home/dialogs/discount_dialog.dart';
import 'package:xpress/presentation/home/dialogs/member_dialog.dart';
import 'package:xpress/presentation/home/dialogs/table_select_dialog.dart';
import 'package:xpress/presentation/home/dialogs/tax_dialog.dart';
import 'package:xpress/presentation/home/dialogs/service_dialog.dart';
import 'package:xpress/presentation/home/dialogs/qris_success_dialog.dart';
import 'package:xpress/core/services/printer_service.dart';
import 'package:xpress/data/dataoutputs/print_dataoutputs.dart';
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
import 'package:xpress/core/widgets/feature_guard.dart';
import 'package:xpress/core/widgets/offline_feature_banner.dart';
import 'package:xpress/data/models/response/discount_response_model.dart'
    as discount_model;
import 'package:dartz/dartz.dart' hide State;
import 'package:xpress/data/models/response/order_error_response.dart';
import 'package:xpress/data/models/response/subscription_limit_response.dart';
import 'package:xpress/data/datasources/subscription_remote_datasource.dart';
import 'package:xpress/presentation/home/dialogs/limit_exceeded_dialog.dart';

// Custom exception for limit exceeded
class LimitExceededException implements Exception {
  final OrderErrorResponse errorResponse;
  LimitExceededException(this.errorResponse);

  @override
  String toString() => errorResponse.message;
}

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
  final FocusNode _totalPayFocusNode = FocusNode();
  bool _isTotalPayFocused = false;
  String? _totalPayErrorMessage;
  static const int _maxDigits = 18;
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
    _totalPayFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isTotalPayFocused = _totalPayFocusNode.hasFocus;
        });
      }
    });

    // ✅ Fast Checkout: Auto fill total bayar dengan total harga + pajak + layanan
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final due = _calculateDueTotal();
      if (due > 0 && totalPayController.text.toIntegerFromText == 0) {
        totalPayController.text = _formatCurrency(due.toString());
      }
    });
  }

  @override
  void dispose() {
    noteController.dispose();
    customerController.dispose();
    totalPayController.dispose();
    _totalPayFocusNode.dispose();
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

      // Check if checkout state is loaded
      final isLoaded = checkoutState.maybeWhen(
        loaded: (_, __, ___, ____, _____, ______, _______, ________, __________,
                ___________) =>
            true,
        orElse: () => false,
      );

      if (!isLoaded) {
        print('❌ ERROR: Checkout state is not loaded!');
        print('   State: ${checkoutState.runtimeType}');
        return false;
      }

      try {
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
            print('   Products count: ${products.length}');
            print('   Total quantity: $totalQuantity');
            print('   Discount: $discountAmount');
            print('   Tax: $tax');
            print('   Service charge: $serviceCharge');

            final amounts =
                _resolveAmounts(products, discountModel, tax, serviceCharge);

            print('   Calculated amounts:');
            print('     Subtotal: ${amounts.subtotal}');
            print('     Discount: ${amounts.discount}');
            print('     Tax: ${amounts.tax}');
            print('     Service: ${amounts.service}');
            print('     Total: ${amounts.total}');

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

            print('   Creating order in local database...');
            localOrderUuid =
                await orderRepository.createOrderLocal(localOrderModel!);
            print('✅ Order saved locally (UUID: $localOrderUuid)');
          },
          orElse: () async {
            print('⚠️ No checkout state available - state is not loaded');
          },
        );
      } catch (e, stackTrace) {
        print('❌ ERROR saving order to local database: $e');
        print('   Stack trace: $stackTrace');
        return false;
      }

      if (localOrderModel == null || localOrderUuid == null) {
        print('❌ Failed to save order locally');
        print('   localOrderModel: ${localOrderModel != null ? "OK" : "NULL"}');
        print('   localOrderUuid: ${localOrderUuid ?? "NULL"}');
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

          // ✅ Skip update order - langsung complete payment saja
          // Order sudah ada dan sudah benar, tidak perlu di-update lagi
          // Langsung complete payment yang akan auto-complete order
          if (isOnline) {
            print(
                '💰 Completing open bill payment directly (no order update needed)...');

            final paymentMethod = isCash ? 'cash' : 'qris';
            final paymentNotes =
                'Pembayaran ${paymentMethod == 'cash' ? 'Tunai' : 'Qris'} Mandiri';

            final receivedAmount = _currentTotalPay();
            final dueAmount = submissionData.amounts.total;

            print('   Order ID: $orderId');
            print('   Payment Method: $paymentMethod');
            print('   Amount: $dueAmount');
            print('   Received: $receivedAmount');

            // ✅ Complete pending payment → Backend auto-completes order → Loyalty points added
            final paymentCompleted =
                await orderRemoteDatasource.completeOpenBillPayment(
              orderId: orderId,
              paymentMethod: paymentMethod,
              amount: dueAmount,
              receivedAmount: receivedAmount > 0 ? receivedAmount : dueAmount,
              notes: paymentNotes,
            );

            if (paymentCompleted && localOrderUuid != null) {
              await orderRepository.markAsSynced(localOrderUuid!,
                  serverId: orderId);
              print('✅ Payment completed! Order auto-completed by backend.');
              print('⭐ Loyalty points automatically added via OrderObserver');

              // Show points earned notification if member selected
              if (_selectedMemberId != null && _selectedMemberId!.isNotEmpty) {
                _showPointsEarnedNotification(dueAmount);
              }
            } else {
              print(
                  '❌ WARNING: Failed to complete payment, but order saved locally');
            }

            return paymentCompleted; // Return payment completion status
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

              // Check for error response (LIMIT_EXCEEDED or other errors)
              if (res.statusCode != 200 && res.statusCode != 201) {
                try {
                  final errorData =
                      jsonDecode(res.body) as Map<String, dynamic>;
                  final errorResponse = OrderErrorResponse.fromJson(errorData);

                  if (errorResponse.isLimitExceeded) {
                    // Throw special exception to be caught by caller
                    throw LimitExceededException(errorResponse);
                  } else {
                    throw Exception(errorResponse.message);
                  }
                } catch (e) {
                  if (e is LimitExceededException) {
                    rethrow;
                  }
                  throw Exception(
                      'Gagal membuat order. Status: ${res.statusCode}');
                }
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

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    // Remove non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return '';
    // Format with thousand separators
    final number = int.tryParse(digitsOnly) ?? 0;
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  int _currentTotalPay() {
    return totalPayController.text.toIntegerFromText;
  }

  void _addToTotalPay(int amount) {
    final current = _currentTotalPay();
    final updated = current + amount;
    totalPayController.text = _formatCurrency(updated.toString());
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

  /// Get tax rate from store settings (returns percentage, e.g., 10 for 10%)
  Future<int> _getTaxRateFromStore() async {
    try {
      final storeDatasource = StoreLocalDatasource();
      final store = await storeDatasource.getStoreDetail();
      final taxRate = store?.settings?.taxRate ?? 0.0;
      return taxRate
          .toInt(); // taxRate is already in percentage (e.g., 10 for 10%)
    } catch (e) {
      print('Error getting tax rate from store: $e');
      return 0;
    }
  }

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
        body['tax_amount'] = amounts.tax.toDouble();
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
          body['tax_amount'] = amounts.tax.toDouble();
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

                                // 🔹 Banner offline untuk QRIS
                                BlocBuilder<OnlineCheckerBloc,
                                    OnlineCheckerState>(
                                  builder: (context, state) {
                                    final isOnline = state.maybeWhen(
                                        online: () => true,
                                        orElse: () => false);
                                    if (!isOnline && !isCash) {
                                      return const Padding(
                                        padding: EdgeInsets.only(bottom: 12),
                                        child: OfflineFeatureBanner(
                                          featureName: 'Pembayaran QRIS',
                                          customMessage:
                                              'Pembayaran QRIS akan segera hadir dalam mode offline. '
                                              'Silakan gunakan metode pembayaran tunai.',
                                          margin: EdgeInsets.zero,
                                          padding: EdgeInsets.all(12),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),

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
                                      child: FeatureGuard(
                                        featureCode: 'qris_payment',
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
                                        disabledChild: CustomButton(
                                          svgIcon: Assets.icons.qr,
                                          filled: false,
                                          label: "QRIS",
                                          onPressed: () {
                                            setState(() {
                                              isCash =
                                                  true; // Auto switch to cash
                                            });
                                          },
                                          disabled: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SpaceHeight(12),

                                // 🔹 TextField Total + Tombol Uang Pas (Baris 3)
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 46,
                                        child: TextField(
                                          controller: totalPayController,
                                          focusNode: _totalPayFocusNode,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                                _maxDigits +
                                                    10), // Allow extra for formatting
                                          ],
                                          onChanged: (value) {
                                            // Remove "Rp." prefix and format
                                            String cleanedValue = value
                                                .replaceAll('Rp.', '')
                                                .trim();
                                            cleanedValue = cleanedValue
                                                .replaceAll('.', '');

                                            // Validasi maksimal digit
                                            if (cleanedValue.length >
                                                _maxDigits) {
                                              // Potong ke maxDigits
                                              cleanedValue = cleanedValue
                                                  .substring(0, _maxDigits);
                                              setState(() {
                                                _totalPayErrorMessage =
                                                    'Maksimal $_maxDigits digit';
                                              });
                                            } else {
                                              setState(() {
                                                _totalPayErrorMessage = null;
                                              });
                                            }

                                            // Format the value
                                            final formatted =
                                                _formatCurrency(cleanedValue);

                                            // Update controller without triggering listener
                                            totalPayController.value =
                                                TextEditingValue(
                                              text: formatted,
                                              selection:
                                                  TextSelection.collapsed(
                                                offset: formatted.length,
                                              ),
                                            );
                                          },
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: "Total Bayar",
                                            prefixText: (_isTotalPayFocused ||
                                                    totalPayController
                                                        .text.isNotEmpty)
                                                ? 'Rp. '
                                                : null,
                                            prefixStyle: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
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
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: BorderSide(
                                                color: _totalPayErrorMessage !=
                                                        null
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: BorderSide(
                                                color: _totalPayErrorMessage !=
                                                        null
                                                    ? Colors.red
                                                    : AppColors.grey,
                                                width: 1.0,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: BorderSide(
                                                color: _totalPayErrorMessage !=
                                                        null
                                                    ? Colors.red
                                                    : Colors.blue,
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: const BorderSide(
                                                  color: Colors.red, width: 2),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                bottomLeft: Radius.circular(8),
                                                topRight: Radius.circular(0),
                                                bottomRight: Radius.circular(0),
                                              ),
                                              borderSide: const BorderSide(
                                                  color: Colors.red, width: 2),
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
                                              _formatCurrency(total.toString());
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

                                // 🔹 Pesan error (Baris 4)
                                if (_totalPayErrorMessage != null) ...[
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      _totalPayErrorMessage!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],

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

                                            // ✅ PRE-CHECK: Check limit before creating order
                                            final onlineCheckerBloc = context
                                                .read<OnlineCheckerBloc>();
                                            if (onlineCheckerBloc.isOnline) {
                                              if (!context.mounted) return;
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (_) => const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );

                                              try {
                                                final subscriptionDatasource =
                                                    SubscriptionRemoteDatasource();
                                                final limitResult =
                                                    await subscriptionDatasource
                                                        .checkLimitStatus();

                                                if (!context.mounted) return;
                                                Navigator.of(context)
                                                    .pop(); // Close loading

                                                bool shouldContinue = true;
                                                limitResult.fold(
                                                  (error) {
                                                    // Error checking limit - continue anyway
                                                    print(
                                                        'Warning: Failed to check limit: $error');
                                                    shouldContinue = true;
                                                  },
                                                  (limitResponse) {
                                                    if (!limitResponse
                                                            .canCreateOrder ||
                                                        limitResponse
                                                                .warningLevel ==
                                                            'exceeded') {
                                                      // Show limit exceeded dialog
                                                      if (context.mounted) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              LimitExceededDialog(
                                                            message: limitResponse
                                                                    .message ??
                                                                'Anda telah mencapai limit transaksi bulanan. Silakan upgrade plan untuk melanjutkan transaksi.',
                                                            recommendedPlan:
                                                                limitResponse
                                                                    .recommendedPlan,
                                                            currentCount:
                                                                limitResponse
                                                                    .currentCount,
                                                            limit: limitResponse
                                                                .limit,
                                                          ),
                                                        );
                                                      }
                                                      shouldContinue =
                                                          false; // Stop here, don't create order
                                                    }
                                                  },
                                                );

                                                // ✅ EARLY RETURN: Jika limit exceeded, jangan lanjutkan
                                                if (!shouldContinue) {
                                                  return;
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  Navigator.of(context)
                                                      .pop(); // Close loading
                                                }
                                                print(
                                                    'Error checking limit: $e');
                                                // Continue anyway if check fails
                                              }
                                            }

                                            // Show loading dialog
                                            if (!context.mounted) return;
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );

                                            try {
                                              // ✅ STEP 1: Create order & payment FIRST
                                              bool orderSuccess = false;
                                              OrderErrorResponse? orderError;

                                              try {
                                                orderSuccess =
                                                    await _submitOrder();
                                              } on LimitExceededException catch (e) {
                                                print(
                                                    '❌ Limit exceeded: ${e.errorResponse.message}');
                                                orderError = e.errorResponse;
                                                orderSuccess = false;
                                              } catch (e) {
                                                print(
                                                    '❌ Error in _submitOrder: $e');
                                                orderSuccess = false;
                                              }

                                              if (!context.mounted) return;
                                              Navigator.of(context)
                                                  .pop(); // Close loading

                                              if (!orderSuccess) {
                                                // Show error dialog
                                                if (context.mounted) {
                                                  if (orderError != null &&
                                                      orderError
                                                          .isLimitExceeded) {
                                                    // Show limit exceeded dialog
                                                    await showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          LimitExceededDialog(
                                                        message: orderError
                                                                ?.message ??
                                                            'Limit tercapai',
                                                        recommendedPlan:
                                                            orderError
                                                                ?.recommendedPlan,
                                                        currentCount: orderError
                                                            ?.currentCount,
                                                        limit:
                                                            orderError?.limit,
                                                      ),
                                                    );
                                                  } else {
                                                    // Show generic error dialog
                                                    await showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          AlertDialog(
                                                        title:
                                                            const Text('Error'),
                                                        content: Text(
                                                          orderError?.message ??
                                                              'Gagal membuat order. Silakan coba lagi.',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'OK'),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                }
                                                return;
                                              }

                                              // ✅ STEP 2: Try to print receipt (non-blocking)
                                              // Cek printer availability terlebih dahulu
                                              bool shouldPrint = false;
                                              try {
                                                final printerService =
                                                    PrinterService();
                                                final isPrinterAvailable =
                                                    await printerService
                                                        .isPrinterAvailable();

                                                if (isPrinterAvailable) {
                                                  // Tampilkan dialog konfirmasi print
                                                  if (context.mounted) {
                                                    final printResult =
                                                        await showDialog<bool>(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder:
                                                          (dialogContext) =>
                                                              AlertDialog(
                                                        backgroundColor:
                                                            AppColors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        title: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                'Cetak Struk',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: Assets
                                                                    .icons
                                                                    .cancel
                                                                    .svg(
                                                                  colorFilter:
                                                                      ColorFilter
                                                                          .mode(
                                                                    AppColors
                                                                        .grey,
                                                                    BlendMode
                                                                        .srcIn,
                                                                  ),
                                                                  height: 32,
                                                                  width: 32,
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        dialogContext,
                                                                        false),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        content: SizedBox(
                                                          width: dialogContext
                                                                  .deviceWidth /
                                                              3,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  'Apakah Anda ingin mencetak struk sekarang?',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        actions: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Button
                                                                    .outlined(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          dialogContext,
                                                                          false),
                                                                  label:
                                                                      'Lewati',
                                                                  height: 50,
                                                                  color: AppColors
                                                                      .greyLight,
                                                                  borderColor:
                                                                      AppColors
                                                                          .grey,
                                                                  textColor:
                                                                      AppColors
                                                                          .grey,
                                                                  borderRadius:
                                                                      8.0,
                                                                  fontSize:
                                                                      16.0,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 12),
                                                              Expanded(
                                                                child: Button
                                                                    .filled(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          dialogContext,
                                                                          true),
                                                                  label:
                                                                      'Cetak',
                                                                  height: 50,
                                                                  color: AppColors
                                                                      .primary,
                                                                  textColor:
                                                                      AppColors
                                                                          .white,
                                                                  borderRadius:
                                                                      8.0,
                                                                  fontSize:
                                                                      16.0,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    shouldPrint =
                                                        printResult ?? false;
                                                  }
                                                } else {
                                                  // Printer tidak tersedia, tampilkan dialog info
                                                  if (context.mounted) {
                                                    await showDialog(
                                                      context: context,
                                                      builder:
                                                          (dialogContext) =>
                                                              AlertDialog(
                                                        backgroundColor:
                                                            AppColors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        title: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              const Text(
                                                                'Printer Tidak Tersedia',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: Assets
                                                                    .icons
                                                                    .cancel
                                                                    .svg(
                                                                  colorFilter:
                                                                      ColorFilter
                                                                          .mode(
                                                                    AppColors
                                                                        .grey,
                                                                    BlendMode
                                                                        .srcIn,
                                                                  ),
                                                                  height: 32,
                                                                  width: 32,
                                                                ),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        dialogContext),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        content: SizedBox(
                                                          width: dialogContext
                                                                  .deviceWidth /
                                                              3,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Text(
                                                                  'Tidak ada printer yang terhubung. Pesanan tetap berhasil dibuat. Anda dapat mencetak struk nanti dari menu transaksi.',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        actions: [
                                                          Button.filled(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    dialogContext),
                                                            label: 'Mengerti',
                                                            height: 50,
                                                            color: AppColors
                                                                .primary,
                                                            textColor:
                                                                AppColors.white,
                                                            borderRadius: 8.0,
                                                            fontSize: 16.0,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                }
                                              } catch (e) {
                                                // Jika ada error saat cek printer, skip printing
                                                print(
                                                    '⚠️ Error checking printer: $e');
                                                shouldPrint = false;
                                              }

                                              // Print di background jika user memilih print
                                              if (shouldPrint &&
                                                  context.mounted) {
                                                // Tampilkan loading indicator untuk printing
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (printContext) =>
                                                      PopScope(
                                                    canPop: false,
                                                    child: AlertDialog(
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          const CircularProgressIndicator(),
                                                          const SizedBox(
                                                              height: 16),
                                                          const Text(
                                                              'Mencetak struk...'),
                                                          const SizedBox(
                                                              height: 8),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      printContext)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'Batal'),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );

                                                // Print di background dengan timeout
                                                _autoPrintReceipt().then((_) {
                                                  if (context.mounted) {
                                                    Navigator.of(context)
                                                        .pop(); // Close print loading
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .check_circle,
                                                                color: Colors
                                                                    .white),
                                                            SizedBox(width: 8),
                                                            Text(
                                                                'Struk berhasil dicetak'),
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            AppColors.success,
                                                        duration: Duration(
                                                            seconds: 2),
                                                      ),
                                                    );
                                                  }
                                                }).catchError((error) {
                                                  if (context.mounted) {
                                                    Navigator.of(context)
                                                        .pop(); // Close print loading
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Row(
                                                          children: [
                                                            const Icon(
                                                                Icons.error,
                                                                color: Colors
                                                                    .white),
                                                            const SizedBox(
                                                                width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                  'Gagal mencetak struk: ${error.toString()}'),
                                                            ),
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            AppColors.danger,
                                                        duration:
                                                            const Duration(
                                                                seconds: 3),
                                                      ),
                                                    );
                                                  }
                                                });
                                              }

                                              // ✅ STEP 3: Show success dialog (info only)
                                              final total =
                                                  _calculateDueTotal();
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
                                                      orderType:
                                                          widget.orderType,
                                                      tableNumber:
                                                          _selectedTableNumber ??
                                                              _parseTableNumber(
                                                                  widget.table
                                                                      ?.tableNumber),
                                                      orderNumber:
                                                          widget.orderNumber,
                                                      onSubmitOrder:
                                                          null, // Already submitted
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                await showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (_) =>
                                                      BlocProvider.value(
                                                    value: context
                                                        .read<CheckoutBloc>(),
                                                    child: QrisSuccessDialog(
                                                      total: total,
                                                      change: change,
                                                      orderType:
                                                          widget.orderType,
                                                      tableNumber:
                                                          _selectedTableNumber ??
                                                              _parseTableNumber(
                                                                  widget.table
                                                                      ?.tableNumber),
                                                      orderNumber:
                                                          widget.orderNumber,
                                                      onSubmitOrder:
                                                          null, // Already submitted
                                                    ),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              Navigator.of(context)
                                                  .pop(); // Close loading
                                              if (context.mounted) {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    title: const Text('Error'),
                                                    content: Text('Error: $e'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text('OK'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
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

  // Auto print receipt after payment success
  Future<void> _autoPrintReceipt() async {
    try {
      final checkoutState = context.read<CheckoutBloc>().state;
      final auth = await AuthLocalDataSource().getAuthData();
      final printerService = PrinterService();

      // Cek printer availability terlebih dahulu
      final isAvailable = await printerService.isPrinterAvailable();
      if (!isAvailable) {
        throw Exception('Printer tidak tersedia');
      }

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
          final paymentAmount = _currentTotalPay();
          final kembalian = paymentAmount - amounts.total;
          final sizeReceipt = await AuthLocalDataSource().getSizeReceipt();
          final paperSize =
              int.tryParse(sizeReceipt) != null ? int.parse(sizeReceipt) : 58;

          // Get operation mode from orderType
          final operationMode = orderType == 'dinein' ? 'dine_in' : 'takeaway';

          // Generate print data
          final printValue = await PrintDataoutputs.instance.printOrderV3(
            products,
            totalQuantity,
            amounts.total,
            isCash ? 'Cash' : 'QRIS',
            paymentAmount,
            kembalian,
            amounts.subtotal, // ✅ Parameter ke-7: subTotal
            amounts.discount, // ✅ Parameter ke-8: discount
            amounts.tax, // ✅ Parameter ke-9: pajak
            amounts.service,
            auth.user?.name ?? 'Kasir',
            draftName.isNotEmpty ? draftName : customerController.text,
            paperSize,
            operationMode: operationMode,
          );

          // Print dengan error handling yang lebih baik
          final printSuccess = await printerService.printBytes(printValue);
          if (!printSuccess) {
            throw Exception(
                'Gagal mencetak struk. Pastikan printer terhubung dan siap digunakan.');
          }
        },
        orElse: () async {
          throw Exception('Tidak ada data untuk dicetak');
        },
      );
    } catch (e) {
      // Re-throw error agar bisa ditangani di caller
      print('Auto print failed: $e');
      rethrow;
    }
  }
}
