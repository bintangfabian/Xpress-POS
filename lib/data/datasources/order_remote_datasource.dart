import 'dart:developer';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/models/response/order_remote_datasource.dart';
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
        final numPart = RegExp(r'(\d+)$').firstMatch(on)?.group(1) ?? '0';
        final next = (int.tryParse(numPart) ?? 0) + 1;
        return '#${next.toString().padLeft(4, '0')}';
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
    String stratDate,
    String endDate,
  ) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeId = await AuthLocalDataSource().getStoreId();
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/orders?start_date=$stratDate&end_date=$endDate');
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
      log("Response: ${response.statusCode}");
      log("Response: ${response.body}");
      if (response.statusCode == 200) {
        return Right(OrderResponseModel.fromJson(response.body));
      } else {
        return const Left("Failed Load Data");
      }
    } catch (e) {
      log("Error: $e");
      return Left("Failed: $e");
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
}
