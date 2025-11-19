import 'dart:developer';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/data/models/response/summary_response_model.dart';
import 'package:xpress/presentation/home/models/order_model.dart';
import 'package:http/http.dart' as http;

void _debugLog(bool enable, String message) {
  if (enable) log(message);
}

class OrderRemoteDatasource {
  Future<String> getNextOrderNumber() async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/orders?per_page=1&sort_by=created_at&sort_direction=desc');
      final headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };
      var res = await http.get(uri, headers: headers);
      if (res.statusCode == 403) {
        res = await http.get(uri, headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
        });
      }
      if (res.statusCode == 200) {
        final map = jsonDecode(res.body);
        List items = [];
        if (map is Map && map['data'] is List) items = map['data'];
        if (items.isEmpty) return '#0001';
        final last = items.first;
        final on = (last['order_number'] ?? '').toString();
        // Try different patterns to extract number
        String numPart = '0';

        // Pattern 1: Extract last 4 digits (e.g., "202510150005" -> "0005")
        final last4Digits = RegExp(r'(\d{4})$').firstMatch(on)?.group(1);
        if (last4Digits != null) {
          numPart = last4Digits;
        } else {
          // Pattern 2: Extract all digits at the end
          final allDigits = RegExp(r'(\d+)$').firstMatch(on)?.group(1);
          if (allDigits != null) {
            // If more than 4 digits, take last 4
            if (allDigits.length > 4) {
              numPart = allDigits.substring(allDigits.length - 4);
            } else {
              numPart = allDigits;
            }
          }
        }
        final next = (int.tryParse(numPart) ?? 0) + 1;
        final result = '#${next.toString().padLeft(4, '0')}';
        return result;
      }
    } catch (_) {}
    return '#0001';
  }

  //save order to remote server
  Future<bool> saveOrder(OrderModel orderModel) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeId = await AuthLocalDataSource().getStoreId();
      final uri =
          Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/orders');
      var response = await http.post(
        uri,
        body: jsonEncode(orderModel.toJson()),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Store-Id': storeId.toString(),
        },
      );
      if (response.statusCode == 403) {
        response = await http.post(
          uri,
          body: jsonEncode(orderModel.toJson()),
          headers: {
            'Authorization': 'Bearer ${authData.token}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        );
      }
      final isOrderSuccess =
          response.statusCode == 200 || response.statusCode == 201;

      if (!isOrderSuccess) {
        return false;
      }

      final orderId = _extractOrderId(response.body);

      if (orderId == null || orderId.isEmpty) {
        // Order created but payment could not be created due to missing order_id
        // Return true because order creation succeeded
        return true;
      }

      final paymentCreated = await _createPayment(
        token: authData.token ?? '',
        storeId: storeId,
        orderModel: orderModel,
        orderId: orderId,
      );

      if (!paymentCreated) {
        // Order created but payment creation failed
        // Return true because order creation succeeded
        return true;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Create payment after order is created
  Future<bool> createPayment({
    required String orderId,
    required String paymentMethod,
    required int amount,
    required int receivedAmount,
    String? notes,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeId = await AuthLocalDataSource().getStoreId();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/payments');

      final defaultNotes =
          'Pembayaran ${paymentMethod.isEmpty ? 'POS' : paymentMethod}';
      final paymentPayload = {
        'order_id': orderId,
        'payment_method': paymentMethod,
        'amount': amount,
        'received_amount': receivedAmount,
        'notes': notes ?? defaultNotes,
      };
      final payload = jsonEncode(paymentPayload);

      var headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Store-Id': storeId.toString(),
      };

      var response = await http.post(uri, body: payload, headers: headers);
      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.post(uri, body: payload, headers: headers);
      }

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _createPayment({
    required String token,
    required int storeId,
    required OrderModel orderModel,
    required String orderId,
  }) async {
    // Note: token and storeId are now retrieved internally in createPayment
    return createPayment(
      orderId: orderId,
      paymentMethod: orderModel.paymentMethod,
      amount: orderModel.total,
      receivedAmount: orderModel.paymentAmount == 0
          ? orderModel.total
          : orderModel.paymentAmount,
      notes:
          'Pembayaran ${orderModel.paymentMethod.isEmpty ? 'POS' : orderModel.paymentMethod}',
    );
  }

  // Public method to extract order_id from API response
  String? extractOrderId(String rawBody) {
    try {
      final dynamic decoded = jsonDecode(rawBody);
      return _resolveOrderId(decoded);
    } catch (e) {
      return null;
    }
  }

  String? _extractOrderId(String rawBody) {
    return extractOrderId(rawBody);
  }

  String? _resolveOrderId(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is Map<String, dynamic>) {
      final normalized = <String, dynamic>{
        for (final entry in data.entries)
          entry.key.toString().toLowerCase(): entry.value
      };

      final looksLikeOrder = normalized.containsKey('order_number') ||
          normalized.containsKey('ordernumber') ||
          (normalized.containsKey('total') &&
              (normalized.containsKey('status') ||
                  normalized.containsKey('payment_status') ||
                  normalized.containsKey('paymentstatus')));

      for (final key in const ['order_id', 'orderid', 'uuid', 'id']) {
        if (!normalized.containsKey(key)) continue;
        final value = normalized[key];

        if (value == null) continue;
        if (value is! num && value is! String) continue;
        final stringValue = value.toString();
        if (stringValue.isEmpty) continue;
        if (key == 'id' && !looksLikeOrder) {
          continue;
        }
        return stringValue;
      }

      for (final key in const ['order', 'data', 'result', 'payload']) {
        if (normalized.containsKey(key)) {
          final nested = _resolveOrderId(normalized[key]);
          if (nested != null && nested.isNotEmpty) {
            return nested;
          }
        }
      }

      // Check nested objects directly
      for (final entry in data.entries) {
        if (entry.value is Map || entry.value is List) {
          final nested = _resolveOrderId(entry.value);
          if (nested != null && nested.isNotEmpty) {
            return nested;
          }
        }
      }
    }

    if (data is List) {
      if (data.isNotEmpty) {
        final nested = _resolveOrderId(data.first);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }

    return null;
  }

  Future<Either<String, OrderResponseModel>> getOrderByRangeDate(
    String startDate,
    String endDate, {
    int perPage = 1000,
    int page = 1,
    bool enableLog = false,
    String? exactDate,
    String? sortField,
    String? sortDirection,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      // Try multiple possible endpoints
      final queryParamsMap = <String, String>{
        'per_page': perPage.toString(),
        'page': page.toString(),
      };

      if (exactDate != null && exactDate.isNotEmpty) {
        queryParamsMap['date'] = exactDate;
      } else {
        queryParamsMap['start_date'] = startDate;
        queryParamsMap['end_date'] = endDate;
      }

      if (sortField != null && sortField.isNotEmpty) {
        queryParamsMap['sort'] = sortField;
      }
      if (sortDirection != null && sortDirection.isNotEmpty) {
        queryParamsMap['direction'] = sortDirection;
      }

      final queryParams = queryParamsMap.entries
          .map((e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      final endpoints = [
        '${Variables.baseUrl}/api/${Variables.apiVersion}/transactions?$queryParams',
        '${Variables.baseUrl}/api/${Variables.apiVersion}/orders?$queryParams',
        '${Variables.baseUrl}/api/${Variables.apiVersion}/sales?$queryParams',
        '${Variables.baseUrl}/api/${Variables.apiVersion}/reports/transactions?$queryParams',
      ];

      for (int i = 0; i < endpoints.length; i++) {
        final uri = Uri.parse(endpoints[i]);
        _debugLog(
            enableLog, "Trying endpoint ${i + 1}/${endpoints.length}: $uri");

        final headers = {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (storeUuid != null && storeUuid.isNotEmpty)
            'X-Store-Id': storeUuid,
        };

        _debugLog(enableLog, "Fetching orders: $uri");
        var response = await http.get(uri, headers: headers);

        if (response.statusCode == 403) {
          // Retry without store header if forbidden
          headers.remove('X-Store-Id');
          response = await http.get(uri, headers: headers);
        }

        _debugLog(enableLog, "Orders Response: ${response.statusCode}");
        _debugLog(enableLog, "Orders Response Body: ${response.body}");

        if (response.statusCode == 200) {
          try {
            final responseData = jsonDecode(response.body);
            _debugLog(enableLog, "=== RAW API RESPONSE DEBUG ===");
            _debugLog(enableLog, "Response type: ${responseData.runtimeType}");
            _debugLog(
                enableLog, "Response keys: ${responseData.keys.toList()}");
            _debugLog(enableLog, "Success: ${responseData['success']}");
            _debugLog(
                enableLog, "Data type: ${responseData['data'].runtimeType}");
            _debugLog(
                enableLog, "Data length: ${responseData['data']?.length}");
            if (responseData['data'] != null &&
                responseData['data'] is List &&
                responseData['data'].isNotEmpty) {
              _debugLog(
                  enableLog, "First data item: ${responseData['data'][0]}");
              _debugLog(enableLog,
                  "First data item keys: ${responseData['data'][0].keys.toList()}");
            }
            _debugLog(enableLog, "=================================");
          } catch (e) {
            _debugLog(enableLog, "Error parsing response: $e");
          }

          final orderResponse = OrderResponseModel.fromJson(response.body);
          _debugLog(
              enableLog, "Parsed orders count: ${orderResponse.data?.length}");
          if (orderResponse.data != null && orderResponse.data!.isNotEmpty) {
            final firstOrder = orderResponse.data!.first;
            _debugLog(enableLog, "=== FIRST ORDER DEBUG ===");
            _debugLog(enableLog, "First order ID: ${firstOrder.id}");
            _debugLog(enableLog,
                "First order orderNumber: ${firstOrder.orderNumber}");
            _debugLog(enableLog,
                "First order totalAmount: ${firstOrder.totalAmount}");
            _debugLog(
                enableLog, "First order subtotal: ${firstOrder.subtotal}");
            _debugLog(
                enableLog, "First order taxAmount: ${firstOrder.taxAmount}");
            _debugLog(enableLog,
                "First order discountAmount: ${firstOrder.discountAmount}");
            _debugLog(enableLog,
                "First order serviceCharge: ${firstOrder.serviceCharge}");
            _debugLog(enableLog,
                "First order paymentMethod: ${firstOrder.paymentMethod}");
            _debugLog(enableLog, "First order status: ${firstOrder.status}");
            _debugLog(enableLog, "First order user: ${firstOrder.user?.name}");
            _debugLog(
                enableLog, "First order table: ${firstOrder.table?.name}");
            _debugLog(enableLog,
                "First order items count: ${firstOrder.items?.length}");
            if (firstOrder.items != null && firstOrder.items!.isNotEmpty) {
              final firstItem = firstOrder.items!.first;
              _debugLog(enableLog,
                  "First item productName: ${firstItem.productName}");
              _debugLog(
                  enableLog, "First item quantity: ${firstItem.quantity}");
              _debugLog(
                  enableLog, "First item totalPrice: ${firstItem.totalPrice}");
            }
            _debugLog(enableLog, "=========================");
          }
          return Right(orderResponse);
        } else {
          _debugLog(enableLog,
              "Endpoint ${i + 1} failed with status: ${response.statusCode}");
          if (i == endpoints.length - 1) {
            return Left(
                "All endpoints failed. Last error: ${response.statusCode}");
          }
        }
      }

      return Left("No working endpoint found");
    } catch (e) {
      return Left("Failed to fetch orders: $e");
    }
  }

  Future<Either<String, SummaryResponseModel>> getSummaryByRangeDate(
    String stratDate,
    String endDate,
  ) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeId = await AuthLocalDataSource().getStoreId();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/reports/summary?start_date=$stratDate&end_date=$endDate');
      var response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-Store-Id': storeId.toString(),
        },
      );
      if (response.statusCode == 403) {
        response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer ${authData.token}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        );
      }
      if (response.statusCode == 200) {
        return Right(SummaryResponseModel.fromJson(response.body));
      } else {
        return const Left("Failed Load Data");
      }
    } catch (e) {
      return Left("Failed: $e");
    }
  }

  Future<Either<String, ItemOrder>> getOrderDetail(String orderId) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/orders/$orderId');

      final headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 403) {
        // Retry without store header if forbidden
        headers.remove('X-Store-Id');
        response = await http.get(uri, headers: headers);
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final order = ItemOrder.fromMap(responseData['data']);
          return Right(order);
        } else {
          return Left("Order not found or invalid response");
        }
      } else {
        return Left("Failed to load order detail: ${response.statusCode}");
      }
    } catch (e) {
      return Left("Failed to fetch order detail: $e");
    }
  }

  // Get list of open bills (orders with status="open" and payment_status="pending")
  Future<Either<String, List<ItemOrder>>> getOpenBills() async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      // Query for orders with status="open"
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/orders?status=open&per_page=100');

      final headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 403) {
        // Retry without store header if forbidden
        headers.remove('X-Store-Id');
        response = await http.get(uri, headers: headers);
      }

      if (response.statusCode == 200) {
        final responseModel = OrderResponseModel.fromJson(response.body);
        final orders = responseModel.data ?? [];

        return Right(orders);
      } else {
        return Left("Failed to load open bills: ${response.statusCode}");
      }
    } catch (e) {
      return Left("Failed to fetch open bills: $e");
    }
  }

  // Create order with payment_mode="open_bill", status="open", payment status="pending"
  Future<Either<String, String>> createOpenBillOrder({
    required Map<String, dynamic> orderData,
    required int totalAmount,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      // Add open bill specific fields
      final modifiedOrderData = Map<String, dynamic>.from(orderData);
      modifiedOrderData['payment_mode'] = 'open_bill';
      modifiedOrderData['status'] = 'open';

      final uri =
          Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/orders');

      final headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      var response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(modifiedOrderData),
      );

      if (response.statusCode == 403) {
        // Retry without store header if forbidden
        headers.remove('X-Store-Id');
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(modifiedOrderData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract order_id from response
        final orderId = extractOrderId(response.body);

        if (orderId != null && orderId.isNotEmpty) {
          // Create payment with status="pending" using the provided totalAmount
          if (totalAmount > 0) {
            await createPendingPayment(
              orderId: orderId,
              amount: totalAmount,
            );
          }

          return Right(orderId);
        } else {
          return Left("Failed to extract order ID from response");
        }
      } else {
        return Left("Failed to create open bill order: ${response.statusCode}");
      }
    } catch (e) {
      return Left("Failed to create open bill order: $e");
    }
  }

  // Create payment with status="pending" for open bill
  Future<bool> createPendingPayment({
    required String orderId,
    required int amount,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/payments');

      final paymentPayload = {
        'order_id': orderId,
        'payment_method': 'pending',
        'amount': amount,
        'status': 'pending',
        'notes': 'Open Bill - Menunggu Pembayaran',
      };

      final payload = jsonEncode(paymentPayload);

      var headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      var response = await http.post(uri, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.post(uri, headers: headers, body: payload);
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Complete open bill payment (update existing pending payment)
  Future<bool> completeOpenBillPayment({
    required String orderId,
    required String paymentMethod,
    required int amount,
    required int receivedAmount,
    String? notes,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/payments/complete-open-bill');

      final paymentPayload = {
        'order_id': orderId,
        'payment_method': paymentMethod,
        'amount': amount,
        'received_amount': receivedAmount,
        'status': 'completed',
        'notes': notes ?? 'Open Bill - Pembayaran Lunas',
      };

      final payload = jsonEncode(paymentPayload);

      var headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      var response = await http.post(uri, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.post(uri, headers: headers, body: payload);
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Update open bill order
  Future<Either<String, String>> updateOpenBillOrder({
    required String orderId,
    required Map<String, dynamic> orderData,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/orders/$orderId');

      final payload = jsonEncode(orderData);

      var headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      var response = await http.put(uri, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.put(uri, headers: headers, body: payload);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(orderId);
      } else {
        return Left('Failed to update open bill: ${response.body}');
      }
    } catch (e) {
      return Left("Failed to update open bill order: $e");
    }
  }

  // Cancel open bill order (update status to cancelled)
  Future<Either<String, String>> cancelOpenBillOrder({
    required String orderId,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/orders/$orderId');

      final payload = jsonEncode({
        'status':
            'cancelled', // ✅ Changed from 'canceled' to 'cancelled' (double-l)
        'restore_inventory': true, // ✅ Restore stock saat cancel
        'cancel_payment':
            true, // ✅ Cancel pending payment saat order dibatalkan
      });

      var headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      var response = await http.put(uri, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.put(uri, headers: headers, body: payload);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(orderId);
      } else {
        return Left('Failed to cancel open bill: ${response.body}');
      }
    } catch (e) {
      return Left("Failed to cancel open bill order: $e");
    }
  }
}
