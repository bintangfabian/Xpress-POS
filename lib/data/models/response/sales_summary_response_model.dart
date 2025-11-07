import 'dart:convert';

class SalesSummaryResponseModel {
  final bool success;
  final String? message;
  final SalesSummaryData? data;

  SalesSummaryResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory SalesSummaryResponseModel.fromJson(String str) =>
      SalesSummaryResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SalesSummaryResponseModel.fromMap(Map<String, dynamic> json) =>
      SalesSummaryResponseModel(
        success: json["success"] ?? false,
        message: json["message"],
        data: json["data"] == null
            ? null
            : SalesSummaryData.fromMap(json["data"]),
      );

  Map<String, dynamic> toMap() => {
        "success": success,
        "message": message,
        "data": data?.toMap(),
      };
}

class SalesSummaryData {
  final int grossSales;
  final int netSales;
  final int grossProfit;
  final int netProfit;
  final int totalTransactions;
  final double grossProfitMargin;
  final int totalRevenue;
  final int totalCost;
  final int totalTax;
  final int totalDiscount;
  final int totalServiceCharge;
  final List<DailySalesStatistic> dailyStatistics;

  SalesSummaryData({
    required this.grossSales,
    required this.netSales,
    required this.grossProfit,
    required this.netProfit,
    required this.totalTransactions,
    required this.grossProfitMargin,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalTax,
    required this.totalDiscount,
    required this.totalServiceCharge,
    required this.dailyStatistics,
  });

  factory SalesSummaryData.fromMap(Map<String, dynamic> json) =>
      SalesSummaryData(
        grossSales: _parseInt(json["gross_sales"]),
        netSales: _parseInt(json["net_sales"]),
        grossProfit: _parseInt(json["gross_profit"]),
        netProfit: _parseInt(json["net_profit"]),
        totalTransactions: _parseInt(json["total_transactions"]),
        grossProfitMargin: _parseDouble(json["gross_profit_margin"]),
        totalRevenue: _parseInt(json["total_revenue"]),
        totalCost: _parseInt(json["total_cost"]),
        totalTax: _parseInt(json["total_tax"]),
        totalDiscount: _parseInt(json["total_discount"]),
        totalServiceCharge: _parseInt(json["total_service_charge"]),
        dailyStatistics: json["daily_statistics"] == null
            ? []
            : List<DailySalesStatistic>.from(json["daily_statistics"]
                .map((x) => DailySalesStatistic.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "gross_sales": grossSales,
        "net_sales": netSales,
        "gross_profit": grossProfit,
        "net_profit": netProfit,
        "total_transactions": totalTransactions,
        "gross_profit_margin": grossProfitMargin,
        "total_revenue": totalRevenue,
        "total_cost": totalCost,
        "total_tax": totalTax,
        "total_discount": totalDiscount,
        "total_service_charge": totalServiceCharge,
        "daily_statistics":
            List<dynamic>.from(dailyStatistics.map((x) => x.toMap())),
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

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

class DailySalesStatistic {
  final String date;
  final int totalSales;
  final int transactionCount;

  DailySalesStatistic({
    required this.date,
    required this.totalSales,
    required this.transactionCount,
  });

  factory DailySalesStatistic.fromMap(Map<String, dynamic> json) =>
      DailySalesStatistic(
        date: json["date"]?.toString() ?? '',
        totalSales: SalesSummaryData._parseInt(json["total_sales"]),
        transactionCount: SalesSummaryData._parseInt(json["transaction_count"]),
      );

  Map<String, dynamic> toMap() => {
        "date": date,
        "total_sales": totalSales,
        "transaction_count": transactionCount,
      };
}
