import 'dart:convert';

class MemberTierStatisticsResponseModel {
  final String? status;
  final TierStatisticsData? data;

  MemberTierStatisticsResponseModel({this.status, this.data});

  factory MemberTierStatisticsResponseModel.fromJson(String str) =>
      MemberTierStatisticsResponseModel.fromMap(json.decode(str));

  factory MemberTierStatisticsResponseModel.fromMap(Map<String, dynamic> json) {
    return MemberTierStatisticsResponseModel(
      status: json['status']?.toString(),
      data: json['data'] == null
          ? null
          : TierStatisticsData.fromMap(
              (json['data'] ?? <String, dynamic>{}) as Map<String, dynamic>,
            ),
    );
  }
}

class TierStatisticsData {
  final int? totalMembers;
  final int? activeMembers;
  final int? inactiveMembers;
  final int? loyaltyPointsIssued;
  final int? loyaltyPointsRedeemed;
  final double? redemptionRate;
  final List<MemberTierStatistic> tiers;

  TierStatisticsData({
    this.totalMembers,
    this.activeMembers,
    this.inactiveMembers,
    this.loyaltyPointsIssued,
    this.loyaltyPointsRedeemed,
    this.redemptionRate,
    this.tiers = const [],
  });

  factory TierStatisticsData.fromMap(Map<String, dynamic> json) {
    final tierList = json['tiers'];
    return TierStatisticsData(
      totalMembers: json['total_members'] is int
          ? json['total_members']
          : int.tryParse(json['total_members']?.toString() ?? ''),
      activeMembers: json['active_members'] is int
          ? json['active_members']
          : int.tryParse(json['active_members']?.toString() ?? ''),
      inactiveMembers: json['inactive_members'] is int
          ? json['inactive_members']
          : int.tryParse(json['inactive_members']?.toString() ?? ''),
      loyaltyPointsIssued: json['loyalty_points_issued'] is int
          ? json['loyalty_points_issued']
          : int.tryParse(json['loyalty_points_issued']?.toString() ?? ''),
      loyaltyPointsRedeemed: json['loyalty_points_redeemed'] is int
          ? json['loyalty_points_redeemed']
          : int.tryParse(json['loyalty_points_redeemed']?.toString() ?? ''),
      redemptionRate: json['redemption_rate'] is num
          ? (json['redemption_rate'] as num).toDouble()
          : double.tryParse(json['redemption_rate']?.toString() ?? ''),
      tiers: tierList == null
          ? <MemberTierStatistic>[]
          : List<MemberTierStatistic>.from(
              (tierList as List).map(
                (e) => MemberTierStatistic.fromMap(
                  (e ?? <String, dynamic>{}) as Map<String, dynamic>,
                ),
              ),
            ),
    );
  }
}

class MemberTierStatistic {
  final String? tierId;
  final String? tierName;
  final String? color;
  final int? memberCount;
  final double? percentage;
  final int? minPoints;
  final int? maxPoints;
  final int? averagePoints;
  final double? averageOrderValue;
  final double? retentionRate;

  MemberTierStatistic({
    this.tierId,
    this.tierName,
    this.color,
    this.memberCount,
    this.percentage,
    this.minPoints,
    this.maxPoints,
    this.averagePoints,
    this.averageOrderValue,
    this.retentionRate,
  });

  factory MemberTierStatistic.fromMap(Map<String, dynamic> json) {
    return MemberTierStatistic(
      tierId: json['tier_id']?.toString() ?? json['id']?.toString(),
      tierName: json['tier_name']?.toString() ?? json['name']?.toString(),
      color: json['color']?.toString(),
      memberCount: json['member_count'] is int
          ? json['member_count']
          : int.tryParse(json['member_count']?.toString() ?? ''),
      percentage: json['percentage'] is num
          ? (json['percentage'] as num).toDouble()
          : double.tryParse(json['percentage']?.toString() ?? ''),
      minPoints: json['min_points'] is int
          ? json['min_points']
          : int.tryParse(json['min_points']?.toString() ?? ''),
      maxPoints: json['max_points'] is int
          ? json['max_points']
          : int.tryParse(json['max_points']?.toString() ?? ''),
      averagePoints: json['average_points'] is int
          ? json['average_points']
          : int.tryParse(json['average_points']?.toString() ?? ''),
      averageOrderValue: json['average_order_value'] is num
          ? (json['average_order_value'] as num).toDouble()
          : double.tryParse(json['average_order_value']?.toString() ?? ''),
      retentionRate: json['retention_rate'] is num
          ? (json['retention_rate'] as num).toDouble()
          : double.tryParse(json['retention_rate']?.toString() ?? ''),
    );
  }
}
