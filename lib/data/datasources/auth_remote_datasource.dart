import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/auth_response_model.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
      String email, String password) async {
    // Input validation
    if (email.isEmpty || !email.contains('@')) {
      return const Left('Email tidak valid');
    }
    if (password.isEmpty || password.length < 6) {
      return const Left('Password minimal 6 karakter');
    }

    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/auth/login');
      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final parsed = AuthResponseModel.fromJson(response.body);
          return Right(parsed);
        } catch (_) {
          // Parsing failed – try to extract message for easier debugging
          return const Left(
              'Login berhasil tetapi format respons tidak sesuai');
        }
      } else {
        // Try extract error message from JSON
        try {
          final map = jsonDecode(response.body) as Map<String, dynamic>;
          final msg =
              (map['message'] ?? map['error'] ?? 'Failed to login').toString();
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
    final url = Uri.parse(
        '${Variables.baseUrl}/api/${Variables.apiVersion}/auth/logout');
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

  Future<Either<String, User>> fetchProfile(String token) async {
    try {
      final url =
          Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/auth/me');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> root =
            jsonDecode(response.body) as Map<String, dynamic>;
        final data = root['data'];

        Map<String, dynamic>? userMap;
        if (data is Map) {
          final userNode = data['user'] ?? data;
          if (userNode is Map) {
            userMap = Map<String, dynamic>.from(
              userNode.map((key, value) => MapEntry(key.toString(), value)),
            );
          }
        } else if (root['user'] is Map) {
          userMap = Map<String, dynamic>.from(
            (root['user'] as Map).map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          );
        } else {
          userMap = Map<String, dynamic>.from(
            root.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          );
        }

        if (userMap == null) {
          return const Left('Data pengguna tidak ditemukan');
        }

        return Right(User.fromMap(userMap));
      }

      return Left('Gagal memverifikasi sesi (${response.statusCode})');
    } catch (e) {
      return Left('Tidak dapat memverifikasi sesi: $e');
    }
  }
}
