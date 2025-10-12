import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:xpress/data/models/request/product_request_model.dart';
import 'package:xpress/data/models/response/add_product_response_model.dart';
import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:http/http.dart' as http;

import '../../core/constants/variables.dart';
import 'auth_local_datasource.dart';

class ProductRemoteDatasource {
  Future<Either<String, ProductResponseModel>> getProducts() async {
    try {
      // Request all products for current store in one shot
      final url = Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/products?per_page=1000');
      final authData = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      Map<String, String> headers = {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
      };
      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      }

      http.Response response = await http.get(url, headers: headers);
      if (response.statusCode == 403) {
        // Retry without store header if server manages context internally
        response = await http.get(url, headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
        });
      }

      if (response.statusCode == 200) {
        try {
          final parsed = ProductResponseModel.fromJson(response.body);
          return Right(parsed);
        } catch (e) {
          // Try to decode and adapt if structure differs
          return Left('Format data produk tidak sesuai');
        }
      } else {
        return Left('Gagal memuat produk (${response.statusCode})');
      }
    } catch (e) {
      return Left('Tidak dapat memuat produk: $e');
    }
  }

  Future<Either<String, AddProductResponseModel>> addProduct(
      ProductRequestModel productRequestModel) async {
    final authData = await AuthLocalDataSource().getAuthData();
    final Map<String, String> headers = {
      'Authorization': 'Bearer ${authData.token}',
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/products'));
    request.fields.addAll(productRequestModel.toMap());
    request.files.add(await http.MultipartFile.fromPath(
        'image', productRequestModel.image!.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    final String body = await response.stream.bytesToString();
    log(response.stream.toString());
    log(response.statusCode.toString());
    if (response.statusCode == 201) {
      return right(AddProductResponseModel.fromJson(body));
    } else {
      return left(body);
    }
  }
}
