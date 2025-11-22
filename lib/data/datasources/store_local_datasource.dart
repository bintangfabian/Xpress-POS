import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/response/store_response_model.dart';

class StoreLocalDatasource {
  static const String _keyStoreDetail = 'store_detail';

  /// Save store detail
  Future<bool> saveStoreDetail(StoreDetail store) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode({
      'id': store.id,
      'name': store.name,
      'email': store.email,
      'phone': store.phone,
      'address': store.address,
      'logo': store.logo,
      'status': store.status,
      'settings': store.settings != null
          ? {
              'currency': store.settings!.currency,
              'tax_rate': store.settings!.taxRate,
              'service_charge_rate': store.settings!.serviceChargeRate,
              'timezone': store.settings!.timezone,
              'receipt_footer': store.settings!.receiptFooter,
            }
          : null,
    });
    return prefs.setString(_keyStoreDetail, json);
  }

  /// Get store detail
  Future<StoreDetail?> getStoreDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyStoreDetail);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
      return StoreDetail.fromMap(jsonData);
    } catch (e) {
      return null;
    }
  }

  /// Clear store detail
  Future<bool> clearStoreDetail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_keyStoreDetail);
  }
}
