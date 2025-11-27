import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/subscription_limit_response.dart';

class SubscriptionRemoteDatasource {
  /// Check transaction limit status
  /// Returns Either with error message (Left) or SubscriptionLimitResponse (Right)
  Future<Either<String, SubscriptionLimitResponse>> checkLimitStatus() async {
    try {
      final authData = await AuthLocalDataSource().getAuthData();
      final storeId = await AuthLocalDataSource().getStoreId();

      final uri = Uri.parse(
        '${Variables.baseUrl}/api/${Variables.apiVersion}/subscription/check-limit',
      );

      final headers = <String, String>{
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (storeId != null && storeId.toString().isNotEmpty) {
        headers['X-Store-Id'] = storeId.toString();
      }

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData =
              jsonDecode(response.body) as Map<String, dynamic>;
          final limitResponse =
              SubscriptionLimitResponse.fromJson(responseData);
          return Right(limitResponse);
        } catch (e) {
          return Left('Gagal memparse response: $e');
        }
      } else {
        // Try to extract error message
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          final message = error?['message'] as String? ??
              'Gagal mengecek status limit. Status: ${response.statusCode}';
          return Left(message);
        } catch (_) {
          return Left(
              'Gagal mengecek status limit. Status: ${response.statusCode}');
        }
      }
    } catch (e) {
      return Left('Terjadi kesalahan: $e');
    }
  }
}
