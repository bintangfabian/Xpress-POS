import 'dart:convert';

class MemberDetailResponseModel {
  final String? status;
  final MemberDetail? data;

  MemberDetailResponseModel({this.status, this.data});

  factory MemberDetailResponseModel.fromJson(String str) =>
      MemberDetailResponseModel.fromMap(json.decode(str));

  factory MemberDetailResponseModel.fromMap(Map<String, dynamic> json) {
    return MemberDetailResponseModel(
      status: json['status']?.toString(),
      data: json['data'] != null ? MemberDetail.fromMap(json['data']) : null,
    );
  }
}

class MemberDetail {
  final String? id;
  final String? memberNumber;
  final String? name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;
  final String? address;
  final int? loyaltyPoints;
  final String? formattedLoyaltyPoints;
  final String? totalSpent;
  final String? formattedTotalSpent;
  final int? visitCount;
  final String? lastVisitAt;
  final bool? isActive;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;
  final MemberTier? tier;
  final List<dynamic>? recentOrders;
  final String? currentTierName;
  final int? tierDiscountPercentage;
  final int? pointsToNextTier;
  final double? averageOrderValue;
  final int? daysSinceLastVisit;

  MemberDetail({
    this.id,
    this.memberNumber,
    this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.address,
    this.loyaltyPoints,
    this.formattedLoyaltyPoints,
    this.totalSpent,
    this.formattedTotalSpent,
    this.visitCount,
    this.lastVisitAt,
    this.isActive,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.tier,
    this.recentOrders,
    this.currentTierName,
    this.tierDiscountPercentage,
    this.pointsToNextTier,
    this.averageOrderValue,
    this.daysSinceLastVisit,
  });

  factory MemberDetail.fromMap(Map<String, dynamic> json) {
    return MemberDetail(
      id: json['id']?.toString(),
      memberNumber: json['member_number']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      address: json['address']?.toString(),
      loyaltyPoints: json['loyalty_points'] is int
          ? json['loyalty_points']
          : int.tryParse(json['loyalty_points']?.toString() ?? '0'),
      formattedLoyaltyPoints: json['formatted_loyalty_points']?.toString(),
      totalSpent: json['total_spent']?.toString(),
      formattedTotalSpent: json['formatted_total_spent']?.toString(),
      visitCount: json['visit_count'] is int
          ? json['visit_count']
          : int.tryParse(json['visit_count']?.toString() ?? '0'),
      lastVisitAt: json['last_visit_at']?.toString(),
      isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active']?.toString() == 'true',
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      tier: json['tier'] != null ? MemberTier.fromMap(json['tier']) : null,
      recentOrders: json['recent_orders'] as List<dynamic>?,
      currentTierName: json['current_tier_name']?.toString(),
      tierDiscountPercentage: json['tier_discount_percentage'] is int
          ? json['tier_discount_percentage']
          : int.tryParse(json['tier_discount_percentage']?.toString() ?? '0'),
      pointsToNextTier: json['points_to_next_tier'] is int
          ? json['points_to_next_tier']
          : int.tryParse(json['points_to_next_tier']?.toString() ?? '0'),
      averageOrderValue: json['average_order_value'] is double
          ? json['average_order_value']
          : double.tryParse(json['average_order_value']?.toString() ?? '0.0'),
      daysSinceLastVisit: json['days_since_last_visit'] is int
          ? json['days_since_last_visit']
          : int.tryParse(json['days_since_last_visit']?.toString() ?? '0'),
    );
  }
}

class MemberTier {
  final String? id;
  final String? name;
  final int? minPoints;
  final int? maxPoints;
  final String? color;

  MemberTier({
    this.id,
    this.name,
    this.minPoints,
    this.maxPoints,
    this.color,
  });

  factory MemberTier.fromMap(Map<String, dynamic> json) {
    return MemberTier(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      minPoints: json['min_points'] is int
          ? json['min_points']
          : int.tryParse(json['min_points']?.toString() ?? '0'),
      maxPoints: json['max_points'] is int
          ? json['max_points']
          : int.tryParse(json['max_points']?.toString() ?? '0'),
      color: json['color']?.toString(),
    );
  }
}
