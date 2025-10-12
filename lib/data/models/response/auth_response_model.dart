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
    final DateTime? emailVerifiedAt;
    final dynamic twoFactorSecret;
    final dynamic twoFactorRecoveryCodes;
    final dynamic twoFactorConfirmedAt;
    final DateTime? createdAt;
    final DateTime? updatedAt;
    final String? role;

    User({
        this.id,
        this.name,
        this.email,
        this.storeId,
        this.emailVerifiedAt,
        this.twoFactorSecret,
        this.twoFactorRecoveryCodes,
        this.twoFactorConfirmedAt,
        this.createdAt,
        this.updatedAt,
        this.role,
    });

    factory User.fromJson(String str) => User.fromMap(json.decode(str));

    String toJson() => json.encode(toMap());

    factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        storeId: json["store_id"]?.toString(),
        emailVerifiedAt: _tryParseDate(json["email_verified_at"]),
        twoFactorSecret: json["two_factor_secret"],
        twoFactorRecoveryCodes: json["two_factor_recovery_codes"],
        twoFactorConfirmedAt: json["two_factor_confirmed_at"],
        createdAt: _tryParseDate(json["created_at"]),
        updatedAt: _tryParseDate(json["updated_at"]),
        role: json["role"],
    );

    Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "email": email,
        "store_id": storeId,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "two_factor_secret": twoFactorSecret,
        "two_factor_recovery_codes": twoFactorRecoveryCodes,
        "two_factor_confirmed_at": twoFactorConfirmedAt,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "role": role,
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
