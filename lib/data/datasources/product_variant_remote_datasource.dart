import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/product_variant_response_model.dart';

/// Remote datasource untuk product variants
/// Fetch data dari backend API /api/v1/products/{id}/variants
class ProductVariantRemoteDatasource {
  final http.Client _client;

  ProductVariantRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  void _log(String message, {Object? error}) {
    log(message, name: 'ProductVariantDatasource', error: error);
  }

  /// Get product variants by product ID
  /// Returns ProductVariantData or null if no variants found
  Future<ProductVariantData?> getProductVariants(String productId) async {
    try {
      _log('========================================');
      _log('Fetching variants for product: $productId');

      // Get auth token and store ID
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      if (auth.token == null || auth.token!.isEmpty) {
        _log('ERROR: No auth token found');
        throw Exception('Not authenticated');
      }

      // Build request
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/products/$productId/variants');

      _log('API URL: $uri');

      final headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      _log('Headers: ${headers.keys.join(", ")}');

      // Make request
      final response = await _client.get(uri, headers: headers);

      _log('Response Status: ${response.statusCode}');
      _log('Response Body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final parsed = ProductVariantResponse.fromJson(response.body);

        if (parsed.success && parsed.data.hasVariants) {
          _log('✅ Found ${parsed.data.variantGroups.length} variant groups');
          _log('   Total options: ${parsed.data.totalOptionsCount}');
          return parsed.data;
        } else {
          _log('ℹ️ Product has no variants');
          return null;
        }
      } else if (response.statusCode == 404) {
        _log('ℹ️ No variants endpoint or product not found');
        return null;
      } else if (response.statusCode == 403) {
        _log('⚠️ Access forbidden - retrying without store header');

        // Retry without X-Store-Id header
        final retryHeaders = {
          'Authorization': 'Bearer ${auth.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };

        final retryResponse = await _client.get(uri, headers: retryHeaders);

        if (retryResponse.statusCode == 200) {
          final parsed = ProductVariantResponse.fromJson(retryResponse.body);
          if (parsed.success && parsed.data.hasVariants) {
            _log(
                '✅ Retry successful - Found ${parsed.data.variantGroups.length} variant groups');
            return parsed.data;
          }
        }

        _log('❌ Retry failed: ${retryResponse.statusCode}');
        return null;
      } else {
        _log('❌ Unexpected response: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      _log('❌ Exception occurred', error: e);
      _log('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Check if product has variants (lightweight check)
  /// Returns true if product has variants, false otherwise
  Future<bool> hasVariants(String productId) async {
    try {
      final variantData = await getProductVariants(productId);
      return variantData != null && variantData.hasVariants;
    } catch (e) {
      _log('Error checking variants for product $productId', error: e);
      return false;
    }
  }

  /// Calculate price with selected variant options
  /// Used for real-time price updates in variant selector
  Future<Map<String, dynamic>?> calculatePrice(
    String productId,
    List<String> variantIds,
  ) async {
    try {
      _log('========================================');
      _log('Calculating price for product: $productId');
      _log('Selected variants: ${variantIds.join(", ")}');

      // Get auth token and store ID
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      if (auth.token == null || auth.token!.isEmpty) {
        _log('ERROR: No auth token found');
        throw Exception('Not authenticated');
      }

      // Build request
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/products/$productId/calculate-price');

      _log('API URL: $uri');

      final headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      final body = json.encode({
        'variant_ids': variantIds,
      });

      _log('Request Body: $body');

      // Make request
      final response = await _client.post(uri, headers: headers, body: body);

      _log('Response Status: ${response.statusCode}');
      _log('Response Body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);

        if (parsed['success'] == true && parsed['data'] != null) {
          _log('✅ Price calculated successfully');
          return parsed['data'] as Map<String, dynamic>;
        } else {
          _log('❌ Invalid response format');
          return null;
        }
      } else if (response.statusCode == 422) {
        _log('⚠️ Validation error - invalid variant selection');
        final parsed = json.decode(response.body);
        _log('Error details: ${parsed['error']}');
        return null;
      } else {
        _log('❌ Unexpected response: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      _log('❌ Exception occurred', error: e);
      _log('Stack trace: $stackTrace');
      return null;
    }
  }
}
