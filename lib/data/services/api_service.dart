import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';

class ApiResponse {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  final bool success;
  final dynamic data;
  final String? message;
}

class ApiService {
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();

  Future<ApiResponse> syncUpload(Map<String, dynamic> payload) async {
    try {
      final authData = await _authLocalDataSource.getAuthData();
      final storeUuid = await _authLocalDataSource.getStoreUuid();

      final url = Uri.parse(
        '${Variables.baseUrl}/api/${Variables.apiVersion}/sync/batch',
      );

      final headers = <String, String>{
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: responseData['data'] ?? {},
          message: responseData['message'] as String?,
        );
      }

      // Try to extract error message
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: false,
          message: errorData['message'] as String? ??
              'Sync failed: ${response.statusCode}',
        );
      } catch (_) {
        return ApiResponse(
          success: false,
          message: 'Sync failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Sync error: $e',
      );
    }
  }

  Future<ApiResponse> syncDownload(DateTime since) async {
    try {
      final authData = await _authLocalDataSource.getAuthData();
      final storeUuid = await _authLocalDataSource.getStoreUuid();

      final sinceTimestamp = since.toIso8601String();
      final url = Uri.parse(
        '${Variables.baseUrl}/api/${Variables.apiVersion}/sync/download?since=$sinceTimestamp',
      );

      final headers = <String, String>{
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: true,
          data: responseData['data'] ?? {},
          message: responseData['message'] as String?,
        );
      }

      // Try to extract error message
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse(
          success: false,
          message: errorData['message'] as String? ??
              'Download failed: ${response.statusCode}',
        );
      } catch (_) {
        return ApiResponse(
          success: false,
          message: 'Download failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Download error: $e',
      );
    }
  }
}
