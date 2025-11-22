import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/category_response_model.dart';
import 'package:http/http.dart' as http;

class CategoryRemoteDatasource {
  Future<Either<String, CategroyResponseModel>> getCategories() async {
    final authData = await AuthLocalDataSource().getAuthData();
    final storeUuid = await AuthLocalDataSource().getStoreUuid();
    var response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/categories'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      },
    );
    if (response.statusCode == 403) {
      response = await http.get(
        Uri.parse(
            '${Variables.baseUrl}/api/${Variables.apiVersion}/categories'),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
        },
      );
    }
    log('Category API Response: ${response.statusCode}');
    log('Category API Body: ${response.body}');
    if (response.statusCode == 200) {
      try {
        final result = CategroyResponseModel.fromJson(response.body);
        log('Category parsed successfully: ${result.data.length} categories');
        return right(result);
      } catch (e) {
        log('Error parsing category response: $e');
        return left('Failed to parse category response: $e');
      }
    } else {
      return left(response.body);
    }
  }
}
