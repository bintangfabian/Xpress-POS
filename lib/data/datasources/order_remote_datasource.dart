import 'dart:developer';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/data/models/response/summary_response_model.dart';
import 'package:xpress/presentation/home/models/order_model.dart';
import 'package:http/http.dart' as http;

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
        log('=== DEBUG ORDER NUMBER ===');
        log('Raw order_number: $on');
        log('Type: ${on.runtimeType}');
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
        log('Extracted number part: $numPart');
        final next = (int.tryParse(numPart) ?? 0) + 1;
        final result = '#${next.toString().padLeft(4, '0')}';
        log('Final result: $result');
        log('========================');
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
      log("OrderModelSingle: $orderModel");
      log("OrderModel: ${orderModel.toJson()}");
      final uri = Uri.parse('${Variables.baseUrl}/api/save-order');
      var response = await http.post(
        uri,
        body: orderModel.toJson(),
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
          body: orderModel.toJson(),
          headers: {
            'Authorization': 'Bearer ${authData.token}',
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        );
      }
      log("Response: ${response.statusCode}");
      log("Response: ${response.body}");
      final isOrderSuccess =
          response.statusCode == 200 || response.statusCode == 201;

      if (!isOrderSuccess) {
        log("Order creation failed with status: ${response.statusCode}");
        return false;
      }

      log("Order created successfully, extracting order_id...");
      final orderId = _extractOrderId(response.body);

      if (orderId == null || orderId.isEmpty) {
        log("ERROR: Unable to resolve order_id from response");
        log("Response body: ${response.body}");
        log("Attempting to parse response as JSON...");

        try {
          final decoded = jsonDecode(response.body);
          log("Decoded response: $decoded");
          log("Response keys: ${decoded is Map ? decoded.keys.toList() : 'not a map'}");
        } catch (e) {
          log("Error parsing response: $e");
        }

        // Jangan return false, karena order sudah terbuat
        // Kita log error tapi tetap return true karena order creation berhasil
        log("WARNING: Order created but payment could not be created due to missing order_id");
        return true;
      }

      log("Order ID extracted: $orderId");
      log("Creating payment...");

      final paymentCreated = await _createPayment(
        token: authData.token ?? '',
        storeId: storeId,
        orderModel: orderModel,
        orderId: orderId,
      );

      if (!paymentCreated) {
        log("WARNING: Order created but payment creation failed for order_id: $orderId");
        // Return true karena order sudah terbuat, meskipun payment gagal
        return true;
      }

      log("Payment created successfully for order_id: $orderId");
      return true;
    } catch (e) {
      log("Error saveOrder: $e");
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
      log('Creating payment with payload: $paymentPayload');

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

      log('Create payment response: ${response.statusCode}');
      log('Create payment body: ${response.body}');

      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      log('Error createPayment: $e');
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
      log('Extracting order_id from response...');
      log('Raw response body: $rawBody');
      final dynamic decoded = jsonDecode(rawBody);
      log('Decoded response type: ${decoded.runtimeType}');
      log('Decoded response: $decoded');

      final orderId = _resolveOrderId(decoded);
      log('Extracted order_id: $orderId');
      return orderId;
    } catch (e) {
      log('Error decoding order response: $e');
      return null;
    }
  }

  String? _extractOrderId(String rawBody) {
    return extractOrderId(rawBody);
  }

  String? _resolveOrderId(dynamic data) {
    if (data == null) {
      log('_resolveOrderId: data is null');
      return null;
    }

    log('_resolveOrderId: data type = ${data.runtimeType}');

    if (data is Map<String, dynamic>) {
      log('_resolveOrderId: data keys = ${data.keys.toList()}');

      final normalized = <String, dynamic>{
        for (final entry in data.entries)
          entry.key.toString().toLowerCase(): entry.value
      };

      log('_resolveOrderId: normalized keys = ${normalized.keys.toList()}');

      final looksLikeOrder = normalized.containsKey('order_number') ||
          normalized.containsKey('ordernumber') ||
          (normalized.containsKey('total') &&
              (normalized.containsKey('status') ||
                  normalized.containsKey('payment_status') ||
                  normalized.containsKey('paymentstatus')));

      log('_resolveOrderId: looksLikeOrder = $looksLikeOrder');

      for (final key in const ['order_id', 'orderid', 'uuid', 'id']) {
        if (!normalized.containsKey(key)) continue;
        final value = normalized[key];
        log('_resolveOrderId: found key "$key" with value = $value (type: ${value.runtimeType})');

        if (value == null) continue;
        if (value is! num && value is! String) continue;
        final stringValue = value.toString();
        if (stringValue.isEmpty) continue;
        if (key == 'id' && !looksLikeOrder) {
          log('_resolveOrderId: skipping "id" key because does not look like order');
          continue;
        }
        log('_resolveOrderId: returning order_id = $stringValue');
        return stringValue;
      }

      for (final key in const ['order', 'data', 'result', 'payload']) {
        if (normalized.containsKey(key)) {
          log('_resolveOrderId: recursively checking key "$key"');
          final nested = _resolveOrderId(normalized[key]);
          if (nested != null && nested.isNotEmpty) {
            log('_resolveOrderId: found order_id in nested "$key" = $nested');
            return nested;
          }
        }
      }

      // Check nested objects directly
      for (final entry in data.entries) {
        if (entry.value is Map || entry.value is List) {
          log('_resolveOrderId: recursively checking entry "${entry.key}"');
          final nested = _resolveOrderId(entry.value);
          if (nested != null && nested.isNotEmpty) {
            log('_resolveOrderId: found order_id in entry "${entry.key}" = $nested');
            return nested;
          }
        }
      }
    }

    if (data is List) {
      log('_resolveOrderId: data is a list with ${data.length} items');
      if (data.isNotEmpty) {
        log('_resolveOrderId: checking first item');
        final nested = _resolveOrderId(data.first);
        if (nested != null && nested.isNotEmpty) {
          log('_resolveOrderId: found order_id in list item = $nested');
          return nested;
        }
      }
    }

    log('_resolveOrderId: could not find order_id');
    return null;
  }

  Future<Either<String, OrderResponseModel>> getOrderByRangeDate(
    String startDate,
    String endDate,
  ) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      // Try multiple possible endpoints
      final endpoints = [
        '${Variables.baseUrl}/api/${Variables.apiVersion}/transactions?start_date=$startDate&end_date=$endDate&per_page=1000',
        '${Variables.baseUrl}/api/${Variables.apiVersion}/orders?start_date=$startDate&end_date=$endDate&per_page=1000',
        '${Variables.baseUrl}/api/${Variables.apiVersion}/sales?start_date=$startDate&end_date=$endDate&per_page=1000',
        '${Variables.baseUrl}/api/${Variables.apiVersion}/reports/transactions?start_date=$startDate&end_date=$endDate&per_page=1000',
      ];

      for (int i = 0; i < endpoints.length; i++) {
        final uri = Uri.parse(endpoints[i]);
        log("Trying endpoint ${i + 1}/${endpoints.length}: $uri");

        final headers = {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (storeUuid != null && storeUuid.isNotEmpty)
            'X-Store-Id': storeUuid,
        };

        log("Fetching orders: $uri");
        var response = await http.get(uri, headers: headers);

        if (response.statusCode == 403) {
          // Retry without store header if forbidden
          headers.remove('X-Store-Id');
          response = await http.get(uri, headers: headers);
        }

        log("Orders Response: ${response.statusCode}");
        log("Orders Response Body: ${response.body}");

        if (response.statusCode == 200) {
          try {
            final responseData = jsonDecode(response.body);
            log("=== RAW API RESPONSE DEBUG ===");
            log("Response type: ${responseData.runtimeType}");
            log("Response keys: ${responseData.keys.toList()}");
            log("Success: ${responseData['success']}");
            log("Data type: ${responseData['data'].runtimeType}");
            log("Data length: ${responseData['data']?.length}");
            if (responseData['data'] != null &&
                responseData['data'] is List &&
                responseData['data'].isNotEmpty) {
              log("First data item: ${responseData['data'][0]}");
              log("First data item keys: ${responseData['data'][0].keys.toList()}");
            }
            log("=================================");
          } catch (e) {
            log("Error parsing response: $e");
          }

          final orderResponse = OrderResponseModel.fromJson(response.body);
          log("Parsed orders count: ${orderResponse.data?.length}");
          if (orderResponse.data != null && orderResponse.data!.isNotEmpty) {
            final firstOrder = orderResponse.data!.first;
            log("=== FIRST ORDER DEBUG ===");
            log("First order ID: ${firstOrder.id}");
            log("First order orderNumber: ${firstOrder.orderNumber}");
            log("First order totalAmount: ${firstOrder.totalAmount}");
            log("First order subtotal: ${firstOrder.subtotal}");
            log("First order taxAmount: ${firstOrder.taxAmount}");
            log("First order discountAmount: ${firstOrder.discountAmount}");
            log("First order serviceCharge: ${firstOrder.serviceCharge}");
            log("First order paymentMethod: ${firstOrder.paymentMethod}");
            log("First order status: ${firstOrder.status}");
            log("First order user: ${firstOrder.user?.name}");
            log("First order table: ${firstOrder.table?.name}");
            log("First order items count: ${firstOrder.items?.length}");
            if (firstOrder.items != null && firstOrder.items!.isNotEmpty) {
              final firstItem = firstOrder.items!.first;
              log("First item productName: ${firstItem.productName}");
              log("First item quantity: ${firstItem.quantity}");
              log("First item totalPrice: ${firstItem.totalPrice}");
            }
            log("=========================");
          }
          return Right(orderResponse);
        } else {
          log("Endpoint ${i + 1} failed with status: ${response.statusCode}");
          if (i == endpoints.length - 1) {
            return Left(
                "All endpoints failed. Last error: ${response.statusCode}");
          }
        }
      }

      return Left("No working endpoint found");
    } catch (e) {
      log("Error fetching orders: $e");
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
          '${Variables.baseUrl}/api/summary?start_date=$stratDate&end_date=$endDate');
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
      if (response.request != null) {
        log("Url: ${response.request!.url}");
      }
      log("Response: ${response.statusCode}");

      log("Response: ${response.body}");
      if (response.statusCode == 200) {
        return Right(SummaryResponseModel.fromJson(response.body));
      } else {
        return const Left("Failed Load Data");
      }
    } catch (e) {
      log("Error: $e");
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

      log("Fetching order detail: $uri");
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 403) {
        // Retry without store header if forbidden
        headers.remove('X-Store-Id');
        response = await http.get(uri, headers: headers);
      }

      log("Order Detail Response: ${response.statusCode}");
      log("Order Detail Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final order = ItemOrder.fromMap(responseData['data']);
          log("=== ORDER DETAIL DEBUG ===");
          log("Order ID: ${order.id}");
          log("Order Number: ${order.orderNumber}");
          log("Total Amount: ${order.totalAmount}");
          log("Subtotal: ${order.subtotal}");
          log("Tax Amount: ${order.taxAmount}");
          log("Discount Amount: ${order.discountAmount}");
          log("Service Charge: ${order.serviceCharge}");
          log("Payment Method: ${order.paymentMethod}");
          log("Status: ${order.status}");
          log("User: ${order.user?.name}");
          log("Table: ${order.table?.name}");
          log("Items: ${order.items?.length}");
          if (order.items != null && order.items!.isNotEmpty) {
            final firstItem = order.items!.first;
            log("First item productName: ${firstItem.productName}");
            log("First item quantity: ${firstItem.quantity}");
            log("First item totalPrice: ${firstItem.totalPrice}");
          }
          log("=========================");
          return Right(order);
        } else {
          return Left("Order not found or invalid response");
        }
      } else {
        return Left("Failed to load order detail: ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching order detail: $e");
      return Left("Failed to fetch order detail: $e");
    }
  }
}
