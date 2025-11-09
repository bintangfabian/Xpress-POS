import 'dart:convert';

class MemberLoyaltyHistoryResponseModel {
  final String? status;
  final List<MemberLoyaltyHistoryEntry> data;
  final PaginationMeta? meta;

  MemberLoyaltyHistoryResponseModel({
    this.status,
    this.data = const [],
    this.meta,
  });

  factory MemberLoyaltyHistoryResponseModel.fromJson(String str) =>
      MemberLoyaltyHistoryResponseModel.fromMap(json.decode(str));

  factory MemberLoyaltyHistoryResponseModel.fromMap(Map<String, dynamic> json) {
    final list = json['data'];
    return MemberLoyaltyHistoryResponseModel(
      status: json['status']?.toString(),
      data: list == null
          ? <MemberLoyaltyHistoryEntry>[]
          : List<MemberLoyaltyHistoryEntry>.from(
              (list as List).map(
                (e) => MemberLoyaltyHistoryEntry.fromMap(
                  (e ?? <String, dynamic>{}) as Map<String, dynamic>,
                ),
              ),
            ),
      meta: json['meta'] == null
          ? null
          : PaginationMeta.fromMap(
              (json['meta'] ?? <String, dynamic>{}) as Map<String, dynamic>,
            ),
    );
  }
}

class MemberLoyaltyHistoryEntry {
  final String? id;
  final String? type;
  final String? source;
  final String? description;
  final int? points;
  final int? balanceBefore;
  final int? balanceAfter;
  final int? amount;
  final String? orderId;
  final String? orderNumber;
  final DateTime? createdAt;

  MemberLoyaltyHistoryEntry({
    this.id,
    this.type,
    this.source,
    this.description,
    this.points,
    this.balanceBefore,
    this.balanceAfter,
    this.amount,
    this.orderId,
    this.orderNumber,
    this.createdAt,
  });

  factory MemberLoyaltyHistoryEntry.fromMap(Map<String, dynamic> json) {
    return MemberLoyaltyHistoryEntry(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      source: json['source']?.toString(),
      description: json['description']?.toString() ?? json['notes']?.toString(),
      points: json['points'] is int
          ? json['points']
          : int.tryParse(json['points']?.toString() ?? ''),
      balanceBefore: json['balance_before'] is int
          ? json['balance_before']
          : int.tryParse(json['balance_before']?.toString() ?? ''),
      balanceAfter: json['balance_after'] is int
          ? json['balance_after']
          : int.tryParse(json['balance_after']?.toString() ?? ''),
      amount: json['amount'] is int
          ? json['amount']
          : int.tryParse(json['amount']?.toString() ?? ''),
      orderId: json['order_id']?.toString(),
      orderNumber: json['order_number']?.toString(),
      createdAt: json['created_at'] == null || json['created_at'].toString().isEmpty
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}

class PaginationMeta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginationMeta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginationMeta.fromMap(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.tryParse(json['current_page']?.toString() ?? ''),
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.tryParse(json['last_page']?.toString() ?? ''),
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.tryParse(json['per_page']?.toString() ?? ''),
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? ''),
      nextPageUrl: json['next_page_url']?.toString(),
      prevPageUrl: json['prev_page_url']?.toString(),
    );
  }
}
