import 'dart:convert';

import 'package:xpress/data/models/response/member_detail_response_model.dart';

class MemberStatisticsResponseModel {
  final String? status;
  final MemberStatistics? data;

  MemberStatisticsResponseModel({this.status, this.data});

  factory MemberStatisticsResponseModel.fromJson(String str) =>
      MemberStatisticsResponseModel.fromMap(json.decode(str));

  factory MemberStatisticsResponseModel.fromMap(Map<String, dynamic> json) {
    return MemberStatisticsResponseModel(
      status: json['status']?.toString(),
      data: json['data'] == null
          ? null
          : MemberStatistics.fromMap(
              (json['data'] ?? <String, dynamic>{}) as Map<String, dynamic>,
            ),
    );
  }
}

class MemberStatistics {
  final int? totalOrders;
  final int? totalVisits;
  final int? loyaltyPoints;
  final int? pointsEarned;
  final int? pointsRedeemed;
  final int? pointsToNextTier;
  final int? daysSinceLastVisit;
  final double? totalSpent;
  final double? averageOrderValue;
  final double? lifetimeValue;
  final double? visitFrequency;
  final double? retentionRate;
  final MemberTier? currentTier;
  final MemberTier? nextTier;

  MemberStatistics({
    this.totalOrders,
    this.totalVisits,
    this.loyaltyPoints,
    this.pointsEarned,
    this.pointsRedeemed,
    this.pointsToNextTier,
    this.daysSinceLastVisit,
    this.totalSpent,
    this.averageOrderValue,
    this.lifetimeValue,
    this.visitFrequency,
    this.retentionRate,
    this.currentTier,
    this.nextTier,
  });

  factory MemberStatistics.fromMap(Map<String, dynamic> json) {
    return MemberStatistics(
      totalOrders: json['total_orders'] is int
          ? json['total_orders']
          : int.tryParse(json['total_orders']?.toString() ?? ''),
      totalVisits: json['total_visits'] is int
          ? json['total_visits']
          : int.tryParse(json['total_visits']?.toString() ?? ''),
      loyaltyPoints: json['loyalty_points'] is int
          ? json['loyalty_points']
          : int.tryParse(json['loyalty_points']?.toString() ?? ''),
      pointsEarned: json['points_earned'] is int
          ? json['points_earned']
          : int.tryParse(json['points_earned']?.toString() ?? ''),
      pointsRedeemed: json['points_redeemed'] is int
          ? json['points_redeemed']
          : int.tryParse(json['points_redeemed']?.toString() ?? ''),
      pointsToNextTier: json['points_to_next_tier'] is int
          ? json['points_to_next_tier']
          : int.tryParse(json['points_to_next_tier']?.toString() ?? ''),
      daysSinceLastVisit: json['days_since_last_visit'] is int
          ? json['days_since_last_visit']
          : int.tryParse(json['days_since_last_visit']?.toString() ?? ''),
      totalSpent: json['total_spent'] is num
          ? (json['total_spent'] as num).toDouble()
          : double.tryParse(json['total_spent']?.toString() ?? ''),
      averageOrderValue: json['average_order_value'] is num
          ? (json['average_order_value'] as num).toDouble()
          : double.tryParse(json['average_order_value']?.toString() ?? ''),
      lifetimeValue: json['lifetime_value'] is num
          ? (json['lifetime_value'] as num).toDouble()
          : double.tryParse(json['lifetime_value']?.toString() ?? ''),
      visitFrequency: json['visit_frequency'] is num
          ? (json['visit_frequency'] as num).toDouble()
          : double.tryParse(json['visit_frequency']?.toString() ?? ''),
      retentionRate: json['retention_rate'] is num
          ? (json['retention_rate'] as num).toDouble()
          : double.tryParse(json['retention_rate']?.toString() ?? ''),
      currentTier: json['current_tier'] == null
          ? null
          : MemberTier.fromMap(
              (json['current_tier'] ?? <String, dynamic>{}) as Map<String, dynamic>,
            ),
      nextTier: json['next_tier'] == null
          ? null
          : MemberTier.fromMap(
              (json['next_tier'] ?? <String, dynamic>{}) as Map<String, dynamic>,
            ),
    );
  }
}
