import 'dart:convert';
import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/cash_session_response_model.dart';
import 'package:xpress/data/models/response/sales_recap_response_model.dart';
import 'package:xpress/data/models/response/best_sellers_response_model.dart';
import 'package:xpress/data/models/response/sales_summary_response_model.dart';

class SalesRemoteDataSource {
  // ==================== CASH SESSION ====================

  /// Get current active cash session or create new one
  Future<Either<String, CashSessionData>> getCurrentCashSession() async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/cash-sessions/current');

      final headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      log('Fetching current cash session: $uri');
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.get(uri, headers: headers);
      }

      log('Cash Session Response: ${response.statusCode}');
      log('Cash Session Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = CashSessionResponseModel.fromJson(response.body);
        if (result.data != null) {
          return Right(result.data!);
        } else {
          return const Left('No active cash session found');
        }
      } else {
        return Left('Failed to get cash session: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting cash session: $e');
      return Left('Failed to get cash session: $e');
    }
  }

  /// Open new cash session
  Future<Either<String, CashSessionData>> openCashSession({
    required int openingBalance,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/cash-sessions');

      final payload = jsonEncode({
        'opening_balance': openingBalance,
      });

      var headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      log('Opening cash session with payload: $payload');
      var response = await http.post(uri, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.post(uri, headers: headers, body: payload);
      }

      log('Open Cash Session Response: ${response.statusCode}');
      log('Open Cash Session Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = CashSessionResponseModel.fromJson(response.body);
        if (result.data != null) {
          return Right(result.data!);
        } else {
          return const Left('Failed to create cash session');
        }
      } else {
        return Left('Failed to open cash session: ${response.statusCode}');
      }
    } catch (e) {
      log('Error opening cash session: $e');
      return Left('Failed to open cash session: $e');
    }
  }

  /// Close cash session
  Future<Either<String, CashSessionData>> closeCashSession({
    required String sessionId,
    required int closingBalance,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/cash-sessions/$sessionId/close');

      final payload = jsonEncode({
        'closing_balance': closingBalance,
      });

      var headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      log('Closing cash session with payload: $payload');
      var response = await http.post(uri, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.post(uri, headers: headers, body: payload);
      }

      log('Close Cash Session Response: ${response.statusCode}');
      log('Close Cash Session Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = CashSessionResponseModel.fromJson(response.body);
        if (result.data != null) {
          return Right(result.data!);
        } else {
          return const Left('Failed to close cash session');
        }
      } else {
        return Left('Failed to close cash session: ${response.statusCode}');
      }
    } catch (e) {
      log('Error closing cash session: $e');
      return Left('Failed to close cash session: $e');
    }
  }

  /// Add expense to cash session
  Future<Either<String, bool>> addExpense({
    required String sessionId,
    required int amount,
    required String description,
    String? category,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/cash-sessions/$sessionId/expenses');

      final payload = jsonEncode({
        'amount': amount,
        'description': description,
        if (category != null) 'category': category,
      });

      var headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      log('Adding expense with payload: $payload');
      var response = await http.post(uri, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.post(uri, headers: headers, body: payload);
      }

      log('Add Expense Response: ${response.statusCode}');
      log('Add Expense Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left('Failed to add expense: ${response.statusCode}');
      }
    } catch (e) {
      log('Error adding expense: $e');
      return Left('Failed to add expense: $e');
    }
  }

  // ==================== SALES RECAP ====================

  /// Get sales recap by date range
  Future<Either<String, SalesRecapData>> getSalesRecap({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/reports/sales-recap?start_date=$startDate&end_date=$endDate');

      final headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      log('Fetching sales recap: $uri');
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.get(uri, headers: headers);
      }

      log('Sales Recap Response: ${response.statusCode}');
      log('Sales Recap Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = SalesRecapResponseModel.fromJson(response.body);
        if (result.data != null) {
          return Right(result.data!);
        } else {
          return const Left('No sales recap data found');
        }
      } else {
        return Left('Failed to get sales recap: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting sales recap: $e');
      return Left('Failed to get sales recap: $e');
    }
  }

  // ==================== BEST SELLERS ====================

  /// Get best selling products and categories
  Future<Either<String, BestSellersData>> getBestSellers({
    required String startDate,
    required String endDate,
    int limit = 10,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/reports/best-sellers?start_date=$startDate&end_date=$endDate&limit=$limit');

      final headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      log('Fetching best sellers: $uri');
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.get(uri, headers: headers);
      }

      log('Best Sellers Response: ${response.statusCode}');
      log('Best Sellers Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = BestSellersResponseModel.fromJson(response.body);
        if (result.data != null) {
          return Right(result.data!);
        } else {
          return const Left('No best sellers data found');
        }
      } else {
        return Left('Failed to get best sellers: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting best sellers: $e');
      return Left('Failed to get best sellers: $e');
    }
  }

  // ==================== SALES SUMMARY ====================

  /// Get sales summary with statistics
  Future<Either<String, SalesSummaryData>> getSalesSummary({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/reports/sales-summary?start_date=$startDate&end_date=$endDate');

      final headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      log('Fetching sales summary: $uri');
      var response = await http.get(uri, headers: headers);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.get(uri, headers: headers);
      }

      log('Sales Summary Response: ${response.statusCode}');
      log('Sales Summary Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = SalesSummaryResponseModel.fromJson(response.body);
        if (result.data != null) {
          return Right(result.data!);
        } else {
          return const Left('No sales summary data found');
        }
      } else {
        return Left('Failed to get sales summary: ${response.statusCode}');
      }
    } catch (e) {
      log('Error getting sales summary: $e');
      return Left('Failed to get sales summary: $e');
    }
  }
}
