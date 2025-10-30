import 'dart:convert';

class StoreDetailResponseModel {
  final StoreDetail? data;

  StoreDetailResponseModel({this.data});

  factory StoreDetailResponseModel.fromJson(String str) {
    final Map<String, dynamic> json =
        jsonDecode(str) as Map<String, dynamic>;
    return StoreDetailResponseModel.fromMap(json);
  }

  factory StoreDetailResponseModel.fromMap(Map<String, dynamic> json) {
    final dynamic raw = json['data'] ?? json['store'];
    if (raw is Map<String, dynamic>) {
      return StoreDetailResponseModel(data: StoreDetail.fromMap(raw));
    }
    return StoreDetailResponseModel(data: null);
  }
}

class StoreDetail {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? logo;
  final String? status;
  final StoreSettings? settings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StoreDetail({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.logo,
    this.status,
    this.settings,
    this.createdAt,
    this.updatedAt,
  });

  factory StoreDetail.fromMap(Map<String, dynamic> json) {
    return StoreDetail(
      id: _readString(json['id']),
      name: _readString(json['name']),
      email: _readString(json['email']),
      phone: _readString(json['phone']),
      address: _readString(json['address']),
      logo: _readString(json['logo']),
      status: _readString(json['status']),
      settings: json['settings'] is Map<String, dynamic>
          ? StoreSettings.fromMap(
              Map<String, dynamic>.from(json['settings'] as Map),
            )
          : null,
      createdAt: _tryParseDate(json['created_at']),
      updatedAt: _tryParseDate(json['updated_at']),
    );
  }
}

class StoreSettings {
  final String? currency;
  final double? taxRate;
  final double? serviceChargeRate;
  final String? timezone;
  final String? receiptFooter;

  StoreSettings({
    this.currency,
    this.taxRate,
    this.serviceChargeRate,
    this.timezone,
    this.receiptFooter,
  });

  factory StoreSettings.fromMap(Map<String, dynamic> json) {
    return StoreSettings(
      currency: _readString(json['currency']),
      taxRate: _readDouble(json['tax_rate']),
      serviceChargeRate: _readDouble(json['service_charge_rate']),
      timezone: _readString(json['timezone']),
      receiptFooter: _readString(json['receipt_footer']),
    );
  }
}

String? _readString(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty ? null : str;
}

double? _readDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  final parsed = double.tryParse(value.toString());
  return parsed;
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  if (value is String && value.isEmpty) return null;
  return DateTime.tryParse(value.toString());
}
