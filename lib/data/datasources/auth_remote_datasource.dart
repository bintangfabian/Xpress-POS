import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
      String email, String password) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final parsed = AuthResponseModel.fromJson(response.body);
          return Right(parsed);
        } catch (_) {
          // Parsing failed – try to extract message for easier debugging
          return const Left('Login berhasil tetapi format respons tidak sesuai');
        }
      } else {
        // Try extract error message from JSON
        try {
          final map = jsonDecode(response.body) as Map<String, dynamic>;
          final msg = (map['message'] ?? map['error'] ?? 'Failed to login').toString();
          return Left(msg);
        } catch (_) {
          return Left('Failed to login (${response.statusCode})');
        }
      }
    } catch (e) {
      return Left('Tidak dapat terhubung ke server: $e');
    }
  }

  //logout
  Future<Either<String, bool>> logout() async {
    final authData = await AuthLocalDataSource().getAuthData();
    final url = Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/auth/logout');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return const Right(true);
    } else {
      return const Left('Failed to logout');
    }
  }
}
