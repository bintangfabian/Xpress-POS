import 'dart:convert';

import 'package:xpress/data/models/response/member_detail_response_model.dart';

class MemberTierResponseModel {
  final String? status;
  final List<MemberTier> data;

  MemberTierResponseModel({
    this.status,
    required this.data,
  });

  factory MemberTierResponseModel.fromJson(String str) =>
      MemberTierResponseModel.fromMap(json.decode(str));

  factory MemberTierResponseModel.fromMap(Map<String, dynamic> json) {
    final list = json['data'];
    return MemberTierResponseModel(
      status: json['status']?.toString(),
      data: list == null
          ? <MemberTier>[]
          : List<MemberTier>.from(
              (list as List).map(
                (e) => MemberTier.fromMap((e ?? <String, dynamic>{}) as Map<String, dynamic>),
              ),
            ),
    );
  }
}
