import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/product_modifier_response_model.dart';

/// Remote datasource untuk product modifiers
/// Fetch data dari backend API /api/v1/products/{id}/modifiers
class ProductModifierRemoteDatasource {
  final http.Client _client;

  ProductModifierRemoteDatasource({http.Client? client})
      : _client = client ?? http.Client();

  void _log(String message, {Object? error}) {
    log(message, name: 'ProductModifierDatasource', error: error);
  }

  /// Get product modifiers by product ID
  /// Returns ProductModifierData or null if no modifiers found
  Future<ProductModifierData?> getProductModifiers(String productId) async {
    try {
      _log('========================================');
      _log('Fetching modifiers for product: $productId');

      // Get auth token and store ID
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      if (auth.token == null || auth.token!.isEmpty) {
        _log('ERROR: No auth token found');
        throw Exception('Not authenticated');
      }

      // Build request
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/products/$productId/modifiers');

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
        final parsed = ProductModifierResponse.fromJson(response.body);

        if (parsed.success && parsed.data.hasModifiers) {
          _log('✅ Found ${parsed.data.modifierGroups.length} modifier groups');
          _log('   Total items: ${parsed.data.totalItemsCount}');
          return parsed.data;
        } else {
          _log('ℹ️ Product has no modifiers');
          return null;
        }
      } else if (response.statusCode == 404) {
        _log('ℹ️ No modifiers endpoint or product not found');
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
          final parsed = ProductModifierResponse.fromJson(retryResponse.body);
          if (parsed.success && parsed.data.hasModifiers) {
            _log(
                '✅ Retry successful - Found ${parsed.data.modifierGroups.length} modifier groups');
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

  /// Check if product has modifiers (lightweight check)
  /// Returns true if product has modifiers, false otherwise
  Future<bool> hasModifiers(String productId) async {
    try {
      final modifierData = await getProductModifiers(productId);
      return modifierData != null && modifierData.hasModifiers;
    } catch (e) {
      _log('Error checking modifiers for product $productId', error: e);
      return false;
    }
  }

  /// Calculate price with selected modifier items
  /// Used for real-time price updates in modifier selector
  Future<Map<String, dynamic>?> calculatePrice(
    String productId,
    List<String> modifierItemIds,
  ) async {
    try {
      _log('========================================');
      _log('Calculating price for product: $productId');
      _log('Selected modifiers: ${modifierItemIds.join(", ")}');

      // Get auth token and store ID
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      if (auth.token == null || auth.token!.isEmpty) {
        _log('ERROR: No auth token found');
        throw Exception('Not authenticated');
      }

      // Build request
      final uri = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/products/$productId/modifiers/calculate-price');

      _log('API URL: $uri');

      final headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      final body = json.encode({
        'modifier_item_ids': modifierItemIds,
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
        _log('⚠️ Validation error - invalid modifier selection');
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
