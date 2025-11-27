class OrderErrorResponse {
  final String code;
  final String message;
  final bool upgradeRequired;
  final String? recommendedPlan;
  final int? currentCount;
  final int? limit;

  OrderErrorResponse({
    required this.code,
    required this.message,
    this.upgradeRequired = false,
    this.recommendedPlan,
    this.currentCount,
    this.limit,
  });

  factory OrderErrorResponse.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>?;
    if (error == null) {
      return OrderErrorResponse(
        code: 'UNKNOWN_ERROR',
        message: 'Terjadi kesalahan saat membuat order',
      );
    }

    return OrderErrorResponse(
      code: error['code'] as String? ?? 'UNKNOWN_ERROR',
      message: error['message'] as String? ?? 'Terjadi kesalahan',
      upgradeRequired: error['upgrade_required'] as bool? ?? false,
      recommendedPlan: error['recommended_plan'] as String?,
      currentCount: error['current_count'] as int?,
      limit: error['limit'] as int?,
    );
  }

  bool get isLimitExceeded => code == 'LIMIT_EXCEEDED';
}
