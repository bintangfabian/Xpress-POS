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
        print('=== DEBUG ORDER NUMBER ===');
        print('Raw order_number: $on');
        print('Type: ${on.runtimeType}');
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
        print('Extracted number part: $numPart');
        final next = (int.tryParse(numPart) ?? 0) + 1;
        final result = '#${next.toString().padLeft(4, '0')}';
        print('Final result: $result');
        print('========================');
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
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      log("Error saveOrder: $e");
      return false;
    }
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
