import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/category_response_model.dart';
import 'package:http/http.dart' as http;

class CategoryRemoteDatasource {
  Future<Either<String, CategroyResponseModel>> getCategories() async {
    final authData = await AuthLocalDataSource().getAuthData();
    final storeId = await AuthLocalDataSource().getStoreId();
    var response = await http.get(
      Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/categories'),
      headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'X-Store-Id': storeId.toString(),
      },
    );
    if (response.statusCode == 403) {
      response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/categories'),
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
        },
      );
    }
    log(response.statusCode.toString());
    log(response.body);
    if (response.statusCode == 200) {
      return right(CategroyResponseModel.fromJson(response.body));
    } else {
      return left(response.body);
    }
  }
}
