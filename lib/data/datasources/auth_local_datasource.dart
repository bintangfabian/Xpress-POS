import 'package:xpress/data/models/response/auth_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalDataSource {
  Future<void> saveAuthData(AuthResponseModel authResponseModel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_data', authResponseModel.toJson());
  }

  Future<void> removeAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
    await prefs.remove('remember_me');
  }

  Future<AuthResponseModel> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('auth_data');

    return AuthResponseModel.fromJson(authData!);
  }

  Future<bool> isAuthDataExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_data');
  }

  // remember me flag
  Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }

  Future<void> saveMidtransServerKey(String serverKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_key', serverKey);
  }

  //get midtrans server key
  Future<String> getMitransServerKey() async {
    final prefs = await SharedPreferences.getInstance();
    final serverKey = prefs.getString('server_key');
    return serverKey ?? '';
  }

  // save size receipt
  Future<void> saveSizeReceipt(String sizeReceipt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('size_receipt', sizeReceipt);
  }

  // get size receipt
  Future<String> getSizeReceipt() async {
    final prefs = await SharedPreferences.getInstance();
    final sizeReceipt = prefs.getString('size_receipt');
    return sizeReceipt ?? '';
  }

  // Store context (multi-tenant)
  // Preferred: store UUID as string
  Future<void> saveStoreUuid(String storeUuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_uuid', storeUuid);
  }

  Future<String?> getStoreUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('store_uuid');
  }

  // Legacy numeric ID support (kept for backward compatibility)
  Future<void> saveStoreId(int storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('store_id', storeId);
  }

  Future<int> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('store_id') ?? 0; // default 0 = not set
  }
}
