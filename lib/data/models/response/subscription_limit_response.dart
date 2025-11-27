class SubscriptionLimitResponse {
  final bool canCreateOrder;
  final int currentCount;
  final int? limit;
  final bool isUnlimited;
  final double usagePercentage;
  final String warningLevel; // 'none', 'warning', 'critical', 'exceeded'
  final PlanInfo plan;
  final String? recommendedPlan;
  final String? message;
  final PeriodInfo period;

  SubscriptionLimitResponse({
    required this.canCreateOrder,
    required this.currentCount,
    this.limit,
    required this.isUnlimited,
    required this.usagePercentage,
    required this.warningLevel,
    required this.plan,
    this.recommendedPlan,
    this.message,
    required this.period,
  });

  factory SubscriptionLimitResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid response format: missing data');
    }

    final planData = data['plan'] as Map<String, dynamic>? ?? {};
    final periodData = data['period'] as Map<String, dynamic>? ?? {};

    return SubscriptionLimitResponse(
      canCreateOrder: data['can_create_order'] as bool? ?? false,
      currentCount: data['current_count'] as int? ?? 0,
      limit: data['limit'] as int?,
      isUnlimited: data['is_unlimited'] as bool? ?? false,
      usagePercentage: (data['usage_percentage'] as num?)?.toDouble() ?? 0.0,
      warningLevel: data['warning_level'] as String? ?? 'none',
      plan: PlanInfo.fromJson(planData),
      recommendedPlan: data['recommended_plan'] as String?,
      message: data['message'] as String?,
      period: PeriodInfo.fromJson(periodData),
    );
  }

  bool get shouldShowWarning =>
      warningLevel == 'warning' ||
      warningLevel == 'critical' ||
      warningLevel == 'exceeded';
}

class PlanInfo {
  final String name;
  final String slug;

  PlanInfo({
    required this.name,
    required this.slug,
  });

  factory PlanInfo.fromJson(Map<String, dynamic> json) {
    return PlanInfo(
      name: json['name'] as String? ?? 'Free',
      slug: json['slug'] as String? ?? 'free',
    );
  }
}

class PeriodInfo {
  final String start;
  final String end;
  final String type;

  PeriodInfo({
    required this.start,
    required this.end,
    required this.type,
  });

  factory PeriodInfo.fromJson(Map<String, dynamic> json) {
    return PeriodInfo(
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      type: json['type'] as String? ?? 'monthly',
    );
  }
}
