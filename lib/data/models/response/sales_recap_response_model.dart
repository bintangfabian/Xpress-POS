import 'dart:convert';

class SalesRecapResponseModel {
  final bool success;
  final String? message;
  final SalesRecapData? data;

  SalesRecapResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory SalesRecapResponseModel.fromJson(String str) =>
      SalesRecapResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SalesRecapResponseModel.fromMap(Map<String, dynamic> json) =>
      SalesRecapResponseModel(
        success: json["success"] ?? false,
        message: json["message"],
        data:
            json["data"] == null ? null : SalesRecapData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data": data?.toMap(),
      };
}

class SalesRecapData {
  final List<PaymentMethodSales> paymentMethods;
  final List<OperationModeSales> operationModes;
  final SalesTotal totals;

  SalesRecapData({
    required this.paymentMethods,
    required this.operationModes,
    required this.totals,
  });

  factory SalesRecapData.fromMap(Map<String, dynamic> json) => SalesRecapData(
        paymentMethods: json["payment_methods"] == null
            ? []
            : List<PaymentMethodSales>.from(json["payment_methods"]
                .map((x) => PaymentMethodSales.fromMap(x))),
        operationModes: json["operation_modes"] == null
            ? []
            : List<OperationModeSales>.from(json["operation_modes"]
                .map((x) => OperationModeSales.fromMap(x))),
        totals: SalesTotal.fromMap(json["totals"] ?? {}),
      );

  Map<String, dynamic> toMap() => {
        "payment_methods":
            List<dynamic>.from(paymentMethods.map((x) => x.toMap())),
        "operation_modes":
            List<dynamic>.from(operationModes.map((x) => x.toMap())),
        "totals": totals.toMap(),
      };
}

class PaymentMethodSales {
  final String paymentMethod;
  final int count;
  final int totalAmount;

  PaymentMethodSales({
    required this.paymentMethod,
    required this.count,
    required this.totalAmount,
  });

  factory PaymentMethodSales.fromMap(Map<String, dynamic> json) =>
      PaymentMethodSales(
        paymentMethod: json["payment_method"]?.toString() ?? '',
        count: _parseInt(json["count"]),
        totalAmount: _parseInt(json["total_amount"]),
      );

  Map<String, dynamic> toMap() => {
        "payment_method": paymentMethod,
        "count": count,
        "total_amount": totalAmount,
      };

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }
}

class OperationModeSales {
  final String operationMode;
  final int count;
  final int totalAmount;

  OperationModeSales({
    required this.operationMode,
    required this.count,
    required this.totalAmount,
  });

  factory OperationModeSales.fromMap(Map<String, dynamic> json) =>
      OperationModeSales(
        operationMode: json["operation_mode"]?.toString() ?? '',
        count: PaymentMethodSales._parseInt(json["count"]),
        totalAmount: PaymentMethodSales._parseInt(json["total_amount"]),
      );

  Map<String, dynamic> toMap() => {
        "operation_mode": operationMode,
        "count": count,
        "total_amount": totalAmount,
      };
}

class SalesTotal {
  final int totalTransactions;
  final int totalCash;
  final int totalNonCash;
  final int grandTotal;

  SalesTotal({
    required this.totalTransactions,
    required this.totalCash,
    required this.totalNonCash,
    required this.grandTotal,
  });

  factory SalesTotal.fromMap(Map<String, dynamic> json) => SalesTotal(
        totalTransactions:
            PaymentMethodSales._parseInt(json["total_transactions"]),
        totalCash: PaymentMethodSales._parseInt(json["total_cash"]),
        totalNonCash: PaymentMethodSales._parseInt(json["total_non_cash"]),
        grandTotal: PaymentMethodSales._parseInt(json["grand_total"]),
      );

  Map<String, dynamic> toMap() => {
        "total_transactions": totalTransactions,
        "total_cash": totalCash,
        "total_non_cash": totalNonCash,
        "grand_total": grandTotal,
      };
}
