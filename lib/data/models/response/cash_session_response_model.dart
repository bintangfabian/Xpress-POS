import 'dart:convert';

class CashSessionResponseModel {
  final bool success;
  final String? message;
  final CashSessionData? data;

  CashSessionResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory CashSessionResponseModel.fromJson(String str) =>
      CashSessionResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CashSessionResponseModel.fromMap(Map<String, dynamic> json) =>
      CashSessionResponseModel(
        success: json["success"] ?? false,
        message: json["message"],
        data:
            json["data"] == null ? null : CashSessionData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data": data?.toMap(),
      };
}

class CashSessionData {
  final String? id;
  final String? userId;
  final String? storeId;
  final String? notes;
  final int openingBalance;
  final int? closingBalance;
  final int? expectedBalance;
  final int cashSales;
  final int cashExpenses;
  final int variance;
  final String status; // 'open' or 'closed'
  final DateTime? openedAt;
  final DateTime? closedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CashExpense>? expenses;

  CashSessionData({
    this.id,
    this.userId,
    this.storeId,
    this.notes,
    required this.openingBalance,
    this.closingBalance,
    this.expectedBalance,
    required this.cashSales,
    required this.cashExpenses,
    required this.variance,
    required this.status,
    this.openedAt,
    this.closedAt,
    this.createdAt,
    this.updatedAt,
    this.expenses,
  });

  factory CashSessionData.fromMap(Map<String, dynamic> json) => CashSessionData(
        id: json["id"]?.toString(),
        userId: json["user_id"]?.toString(),
        storeId: json["store_id"]?.toString(),
        notes: json["notes"]?.toString(),
        openingBalance: _parseInt(json["opening_balance"]),
        closingBalance: _parseInt(json["closing_balance"]),
        expectedBalance: _parseInt(json["expected_balance"]),
        cashSales: _parseInt(json["cash_sales"]),
        cashExpenses: _parseInt(json["cash_expenses"]),
        variance: _parseInt(json["variance"]),
        status: json["status"]?.toString() ?? 'open',
        openedAt: json["opened_at"] == null
            ? null
            : DateTime.parse(json["opened_at"]),
        closedAt: json["closed_at"] == null
            ? null
            : DateTime.parse(json["closed_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        expenses: json["expenses"] == null
            ? null
            : List<CashExpense>.from(
                json["expenses"].map((x) => CashExpense.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "user_id": userId,
        "store_id": storeId,
        "notes": notes,
        "opening_balance": openingBalance,
        "closing_balance": closingBalance,
        "expected_balance": expectedBalance,
        "cash_sales": cashSales,
        "cash_expenses": cashExpenses,
        "variance": variance,
        "status": status,
        "opened_at": openedAt?.toIso8601String(),
        "closed_at": closedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "expenses": expenses == null
            ? null
            : List<dynamic>.from(expenses!.map((x) => x.toMap())),
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return 0;

      final directInt = int.tryParse(trimmed);
      if (directInt != null) return directInt;

      final directDouble = double.tryParse(trimmed);
      if (directDouble != null) return directDouble.round();

      final withoutComma = trimmed.replaceAll(',', '');
      final commaFreeDouble = double.tryParse(withoutComma);
      if (commaFreeDouble != null) return commaFreeDouble.round();

      final europeanFormatted =
          trimmed.replaceAll('.', '').replaceAll(',', '.');
      final euroDouble = double.tryParse(europeanFormatted);
      if (euroDouble != null) return euroDouble.round();

      final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9-]'), '');
      if (digitsOnly.isEmpty) return 0;
      return int.tryParse(digitsOnly) ?? 0;
    }
    return 0;
  }
}

class CashExpense {
  final String? id;
  final String? cashSessionId;
  final int amount;
  final String? description;
  final String? category;
  final DateTime? createdAt;

  CashExpense({
    this.id,
    this.cashSessionId,
    required this.amount,
    this.description,
    this.category,
    this.createdAt,
  });

  factory CashExpense.fromMap(Map<String, dynamic> json) => CashExpense(
        id: json["id"]?.toString(),
        cashSessionId: json["cash_session_id"]?.toString(),
        amount: CashSessionData._parseInt(json["amount"]),
        description: json["description"]?.toString(),
        category: json["category"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "cash_session_id": cashSessionId,
        "amount": amount,
        "description": description,
        "category": category,
        "created_at": createdAt?.toIso8601String(),
      };
}
