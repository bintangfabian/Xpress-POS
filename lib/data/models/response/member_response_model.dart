import 'dart:convert';

class MemberResponseModel {
  final String? status;
  final List<Member>? data;

  MemberResponseModel({this.status, this.data});

  factory MemberResponseModel.fromJson(String str) =>
      MemberResponseModel.fromMap(json.decode(str));

  factory MemberResponseModel.fromMap(Map<String, dynamic> json) {
    final list = json['data'];
    return MemberResponseModel(
      status: json['status']?.toString(),
      data: list == null
          ? []
          : List<Member>.from(
              (list as List).map((e) => Member.fromMap(e as Map<String, dynamic>))),
    );
  }
}

class Member {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? dateOfBirth;

  Member({this.id, this.name, this.email, this.phone, this.dateOfBirth});

  factory Member.fromMap(Map<String, dynamic> json) {
    return Member(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? json['telp']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
    );
  }
}
