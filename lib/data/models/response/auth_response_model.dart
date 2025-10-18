import 'dart:convert';

class AuthResponseModel {
    final String? status;
    final String? token;
    final User? user;

    AuthResponseModel({
        this.status,
        this.token,
        this.user,
    });

    factory AuthResponseModel.fromJson(String str) => AuthResponseModel.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory AuthResponseModel.fromMap(Map<String, dynamic> json) {
      // Some backends return nested { data: { token, user } }
      final root = json;
      final data = (root['data'] is Map<String, dynamic>)
          ? root['data'] as Map<String, dynamic>
          : root;

      final token = (data['token'] ?? data['access_token']) as String?;
      final userRaw = (data['user'] ?? root['user']);

      return AuthResponseModel(
        status: (root['status'] ?? root['message']) as String?,
        token: token,
        user: userRaw is Map<String, dynamic> ? User.fromMap(userRaw) : null,
      );
    }

    Map<String, dynamic> toMap() => {
        "status": status,
        "token": token,
        "user": user?.toMap(),
    };
}

class User {
    final int? id;
    final String? name;
    final String? email;
    final String? storeId;
    final Store? store;
    final DateTime? emailVerifiedAt;
    final dynamic twoFactorSecret;
    final dynamic twoFactorRecoveryCodes;
    final dynamic twoFactorConfirmedAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final String? role;
    final List<String>? roles;

    User({
        this.id,
        this.name,
        this.email,
        this.storeId,
        this.store,
        this.emailVerifiedAt,
        this.twoFactorSecret,
        this.twoFactorRecoveryCodes,
        this.twoFactorConfirmedAt,
        this.createdAt,
        this.updatedAt,
        this.role,
        this.roles,
    });

    factory User.fromJson(String str) => User.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: _readString(json["name"]),
        email: _readString(json["email"]),
        storeId: _resolveStoreId(json),
        store: _resolveStore(json),
        emailVerifiedAt: _tryParseDate(json["email_verified_at"]),
        twoFactorSecret: json["two_factor_secret"],
        twoFactorRecoveryCodes: json["two_factor_recovery_codes"],
        twoFactorConfirmedAt: json["two_factor_confirmed_at"],
        createdAt: _tryParseDate(json["created_at"]),
        updatedAt: _tryParseDate(json["updated_at"]),
        role: json["role"] ?? _firstRole(json["roles"]),
        roles: _parseRoles(json["roles"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "store_id": storeId,
        "store": store?.toMap(),
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "two_factor_secret": twoFactorSecret,
        "two_factor_recovery_codes": twoFactorRecoveryCodes,
        "two_factor_confirmed_at": twoFactorConfirmedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "role": role,
        "roles": roles,
    };
}

class Store {
    final String? id;
    final String? name;
    final String? status;

    Store({
        this.id,
        this.name,
        this.status,
    });

    factory Store.fromJson(String str) => Store.fromMap(json.decode(str));

    factory Store.fromMap(Map<String, dynamic> json) => Store(
        id: _readString(
          json["id"] ?? json["uuid"] ?? json["store_id"] ?? json["store_uuid"],
        ),
        name: _readString(json["name"] ?? json["store_name"]),
        status: _readString(json["status"] ?? json["store_status"]),
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "status": status,
    };
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  if (value is String && value.isEmpty) return null;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
}

Store? _parseStore(dynamic value) {
  if (value is Map) {
    final mapped = value.map(
      (key, val) => MapEntry(key.toString(), val),
    );
    return Store.fromMap(Map<String, dynamic>.from(mapped));
  }
  return null;
}

List<String>? _parseRoles(dynamic value) {
  if (value is List) {
    final result = <String>[];
    for (final item in value) {
      if (item == null) continue;
      if (item is String) {
        final trimmed = item.trim();
        if (trimmed.isNotEmpty) result.add(trimmed);
      } else if (item is Map) {
        final nameCandidates = [
          item['name'],
          item['display_name'],
          item['slug'],
          item['role'],
        ];
        final picked = nameCandidates
            .cast<String?>()
            .firstWhere((element) => element != null && element.trim().isNotEmpty, orElse: () => null);
        if (picked != null) {
          result.add(picked.trim());
        } else {
          result.add(item.toString());
        }
      } else {
        final str = item.toString().trim();
        if (str.isNotEmpty) result.add(str);
      }
    }
    return result.isEmpty ? null : result;
  } else if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return [trimmed];
  }
  return null;
}

String? _firstRole(dynamic value) {
  final roles = _parseRoles(value);
  if (roles == null || roles.isEmpty) return null;
  return roles.first;
}

String? _readString(dynamic value) {
  if (value == null) return null;
  if (value is String) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
  return value.toString();
}

String? _resolveStoreId(Map<String, dynamic> json) {
  final fromDirect = json["store_id"] ?? json["store_uuid"] ?? json["storeId"];
  if (fromDirect != null && fromDirect.toString().isNotEmpty) {
    return fromDirect.toString();
  }
  final store = json["store"];
  if (store is Map && store["id"] != null) {
    return store["id"].toString();
  }
  final storeObj = _parseStore(store);
  if (storeObj?.id != null && storeObj!.id!.isNotEmpty) {
    return storeObj.id;
  }
  return null;
}

Store? _resolveStore(Map<String, dynamic> json) {
  final fromMap = _parseStore(json["store"]);
  if (fromMap != null) {
    return fromMap;
  }
  final storeName = _readString(json["store_name"] ?? json["storeName"]);
  final storeId = _readString(json["store_id"] ?? json["store_uuid"]);
  if (storeName != null || storeId != null) {
    return Store(
      id: storeId,
      name: storeName,
      status: _readString(json["store_status"]),
    );
  }
  return null;
}
