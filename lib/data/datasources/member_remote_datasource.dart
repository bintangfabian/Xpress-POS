import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/member_response_model.dart';
import 'package:xpress/data/models/response/member_detail_response_model.dart';
import 'package:xpress/data/models/response/member_tier_response_model.dart';
import 'package:xpress/data/models/response/member_tier_statistics_response_model.dart';
import 'package:xpress/data/models/response/member_statistics_response_model.dart';
import 'package:xpress/data/models/response/member_loyalty_history_response_model.dart';

class MemberRemoteDatasource {
  Future<Either<String, MemberResponseModel>> getMembers() async {
    try {
      final url =
          Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/members');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      Map<String, String> headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
      };
      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else {
        headers['X-Store-Id'] = storeId.toString();
      }

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 403) {
        // Retry without store header if forbidden
        headers.remove('X-Store-Id');
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        return Right(MemberResponseModel.fromJson(response.body));
      }
      return Left('Failed to get members (${response.statusCode})');
    } catch (e) {
      return Left('Failed to get members: $e');
    }
  }

  Future<Either<String, bool>> createMember({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    String? address,
  }) async {
    try {
      final url =
          Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/members');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      Map<String, String> headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else {
        headers['X-Store-Id'] = storeId.toString();
      }

      final payload = jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'telp': phone,
        'date_of_birth': dateOfBirth,
        if (address != null && address.isNotEmpty) 'address': address,
      });

      var response = await http.post(url, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.post(url, headers: headers, body: payload);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      }
      return Left('Failed to create member (${response.statusCode})');
    } catch (e) {
      return Left('Failed to create member: $e');
    }
  }

  Future<Either<String, MemberDetailResponseModel>> getMemberDetail(
      String id) async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members/$id');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      Map<String, String> headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
      };
      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else {
        headers['X-Store-Id'] = storeId.toString();
      }

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 403) {
        // Retry without store header if forbidden
        headers.remove('X-Store-Id');
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        return Right(MemberDetailResponseModel.fromJson(response.body));
      }
      return Left('Failed to get member detail (${response.statusCode})');
    } catch (e) {
      return Left('Failed to get member detail: $e');
    }
  }

  Future<Either<String, bool>> updateMember({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
    String? address,
  }) async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members/$id');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      Map<String, String> headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else {
        headers['X-Store-Id'] = storeId.toString();
      }

      final payload = jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'telp': phone,
        'date_of_birth': dateOfBirth,
        if (address != null && address.isNotEmpty) 'address': address,
      });

      var response = await http.put(url, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.put(url, headers: headers, body: payload);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      }
      return Left('Failed to update member (${response.statusCode})');
    } catch (e) {
      return Left('Failed to update member: $e');
    }
  }

  Future<Either<String, bool>> deleteMember(String id) async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members/$id');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      Map<String, String> headers = {
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else {
        headers['X-Store-Id'] = storeId.toString();
      }

      // Soft delete: set is_active to 0 instead of hard delete
      final payload = jsonEncode({
        'is_active': 0,
      });

      var response = await http.put(url, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.put(url, headers: headers, body: payload);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return const Right(true);
      }

      return Left('Failed to deactivate member (${response.statusCode})');
    } catch (e) {
      return Left('Failed to deactivate member: $e');
    }
  }

  Future<Either<String, MemberTierResponseModel>> getMemberTiers() async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members/tiers');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      final headers = <String, String>{
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
      };
      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else if (storeId != null) {
        headers['X-Store-Id'] = storeId.toString();
      }

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        return Right(MemberTierResponseModel.fromJson(response.body));
      }
      return Left('Failed to get member tiers (${response.statusCode})');
    } catch (e) {
      return Left('Failed to get member tiers: $e');
    }
  }

  Future<Either<String, MemberTierStatisticsResponseModel>>
      getMemberTierStatistics() async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members/tier-statistics');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      final headers = <String, String>{
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
      };
      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else if (storeId != null) {
        headers['X-Store-Id'] = storeId.toString();
      }

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        return Right(
            MemberTierStatisticsResponseModel.fromJson(response.body));
      }
      return Left(
          'Failed to get member tier statistics (${response.statusCode})');
    } catch (e) {
      return Left('Failed to get member tier statistics: $e');
    }
  }

  Future<Either<String, MemberStatisticsResponseModel>> getMemberStatistics(
      String id) async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members/$id/statistics');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      final headers = <String, String>{
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
      };
      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else if (storeId != null) {
        headers['X-Store-Id'] = storeId.toString();
      }

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        return Right(MemberStatisticsResponseModel.fromJson(response.body));
      }
      return Left(
          'Failed to get member statistics (${response.statusCode})');
    } catch (e) {
      return Left('Failed to get member statistics: $e');
    }
  }

  Future<Either<String, MemberLoyaltyHistoryResponseModel>>
      getMemberLoyaltyHistory(
    String id, {
    int page = 1,
  }) async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members/$id/loyalty-history?page=$page');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      final headers = <String, String>{
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
      };
      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else if (storeId != null) {
        headers['X-Store-Id'] = storeId.toString();
      }

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        return Right(
            MemberLoyaltyHistoryResponseModel.fromJson(response.body));
      }
      return Left(
          'Failed to get member loyalty history (${response.statusCode})');
    } catch (e) {
      return Left('Failed to get member loyalty history: $e');
    }
  }

  Future<Either<String, bool>> addLoyaltyPoints({
    required String memberId,
    int? points,
    int? amount,
    String? orderId,
    String? notes,
  }) {
    return _postLoyaltyMutation(
      memberId: memberId,
      action: 'add',
      body: {
        if (points != null) 'points': points,
        if (amount != null) 'amount': amount,
        if (orderId != null) 'order_id': orderId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  Future<Either<String, bool>> redeemLoyaltyPoints({
    required String memberId,
    required int points,
    String? orderId,
    String? notes,
  }) {
    return _postLoyaltyMutation(
      memberId: memberId,
      action: 'redeem',
      body: {
        'points': points,
        if (orderId != null) 'order_id': orderId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  Future<Either<String, bool>> adjustLoyaltyPoints({
    required String memberId,
    required int points,
    String? reason,
  }) {
    return _postLoyaltyMutation(
      memberId: memberId,
      action: 'adjust',
      body: {
        'points': points,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }

  Future<Either<String, bool>> _postLoyaltyMutation({
    required String memberId,
    required String action,
    required Map<String, dynamic> body,
  }) async {
    try {
      if (body.isEmpty) {
        return Left('Loyalty payload cannot be empty');
      }

      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/members/$memberId/loyalty-points/$action');
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final storeId = await AuthLocalDataSource().getStoreId();

      final headers = <String, String>{
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else if (storeId != null) {
        headers['X-Store-Id'] = storeId.toString();
      }

      final payload = jsonEncode(body);
      var response = await http.post(url, headers: headers, body: payload);

      if (response.statusCode == 403) {
        headers.remove('X-Store-Id');
        response = await http.post(url, headers: headers, body: payload);
      }

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        return const Right(true);
      }
      return Left(
          'Failed to $action loyalty points (${response.statusCode})');
    } catch (e) {
      return Left('Failed to $action loyalty points: $e');
    }
  }
}
