import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/models/response/auth_response_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource({
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _tokenKey = 'token';
  static const _userKey = 'user';
  static const _statusKey = 'status';
  static const _isAuthenticatedKey = 'isAuthenticated';
  static const _lastLoginKey = 'lastLoginAt';
  static const _loginModeKey = 'loginMode';

  final FlutterSecureStorage _secureStorage;

  Box<dynamic> get _authBox => Hive.box('auth');

  Future<void> saveAuthData(
    AuthResponseModel authResponseModel, {
    String mode = 'online',
  }) async {
    final box = _authBox;
    final userMap = authResponseModel.user?.toMap();
    if (userMap != null) {
      await box.put(_userKey, userMap);
    }
    await box.put(_statusKey, authResponseModel.status);
    await box.put(_isAuthenticatedKey, true);
    await box.put(_loginModeKey, mode);
    await box.put(_lastLoginKey, TimezoneHelper.now().toIso8601String());

    if (authResponseModel.token != null &&
        authResponseModel.token!.isNotEmpty) {
      await _secureStorage.write(
          key: _tokenKey, value: authResponseModel.token);
    }
  }

  Future<void> markOfflineLogin() async {
    final box = _authBox;
    await box.put(_loginModeKey, 'offline');
    await box.put(_isAuthenticatedKey, true);
    if (!box.containsKey(_lastLoginKey)) {
      await box.put(_lastLoginKey, TimezoneHelper.now().toIso8601String());
    }
  }

  Future<String> getLoginMode() async {
    final box = _authBox;
    return (box.get(_loginModeKey) as String?) ?? 'online';
  }

  Future<void> setLoginMode(String mode) async {
    final box = _authBox;
    await box.put(_loginModeKey, mode);
  }

  Future<AuthResponseModel> getAuthData() async {
    final box = _authBox;
    final userRaw = box.get(_userKey);
    final token = await _secureStorage.read(key: _tokenKey);
    final status = box.get(_statusKey) as String?;

    if (userRaw is Map && token != null && token.isNotEmpty) {
      final normalized = Map<String, dynamic>.from(
        userRaw.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
      final user = User.fromMap(normalized);
      return AuthResponseModel(
        status: status,
        token: token,
        user: user,
      );
    }

    // Fallback to legacy shared preferences storage (migration path)
    final prefs = await SharedPreferences.getInstance();
    final authData = prefs.getString('auth_data');
    if (authData != null) {
      final parsed = AuthResponseModel.fromJson(authData);
      await saveAuthData(parsed);
      await prefs.remove('auth_data');
      return parsed;
    }

    throw StateError('No authenticated session found');
  }

  Future<String?> getToken() {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<bool> hasCachedUser() async {
    final box = _authBox;
    return box.containsKey(_userKey);
  }

  Future<bool> isAuthenticated() async {
    final box = _authBox;
    final isAuthenticated =
        box.get(_isAuthenticatedKey, defaultValue: false) as bool;
    final token = await _secureStorage.read(key: _tokenKey);
    return isAuthenticated && token != null && token.isNotEmpty;
  }

  Future<void> updateCachedUser(User user) async {
    final box = _authBox;
    await box.put(_userKey, user.toMap());
    await box.put(_lastLoginKey, TimezoneHelper.now().toIso8601String());
  }

  Future<DateTime?> getLastLoginAt() async {
    final box = _authBox;
    final raw = box.get(_lastLoginKey) as String?;
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> removeAuthData() async {
    final box = _authBox;
    await box.delete(_userKey);
    await box.delete(_statusKey);
    await box.put(_isAuthenticatedKey, false);
    await box.delete(_loginModeKey);
    await box.delete(_lastLoginKey);
    await _secureStorage.delete(key: _tokenKey);

    // Legacy cleanup
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_data');
    await prefs.remove('remember_me');
  }

  // remember me flag (legacy support, kept for existing flows)
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

  Future<String> getMitransServerKey() async {
    final prefs = await SharedPreferences.getInstance();
    final serverKey = prefs.getString('server_key');
    return serverKey ?? '';
  }

  Future<void> saveSizeReceipt(String sizeReceipt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('size_receipt', sizeReceipt);
  }

  Future<String> getSizeReceipt() async {
    final prefs = await SharedPreferences.getInstance();
    final sizeReceipt = prefs.getString('size_receipt');
    return sizeReceipt ?? '';
  }

  Future<void> saveStoreUuid(String storeUuid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_uuid', storeUuid);
  }

  Future<String?> getStoreUuid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('store_uuid');
  }

  Future<void> saveStoreId(int storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('store_id', storeId);
  }

  Future<int> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('store_id') ?? 0;
  }
}
