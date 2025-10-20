import 'package:dartz/dartz.dart';
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';
import 'package:http/http.dart' as http;

class DiscountRemoteDatasource {
  Future<Either<String, DiscountResponseModel>> getDiscounts() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/discounts');
      final authData = await AuthLocalDataSource().getAuthData();
      final storeId = await AuthLocalDataSource().getStoreId();
      var response = await http.get(url, headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'X-Store-Id': storeId.toString(),
      });
      if (response.statusCode == 403) {
        response = await http.get(url, headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
        });
      }

      if (response.statusCode == 200) {
        return Right(DiscountResponseModel.fromJson(response.body));
      } else {
        return Left('Failed to get discounts (${response.statusCode})');
      }
    } catch (e) {
      return Left('Failed to get discounts: $e');
    }
  }

  Future<Either<String, bool>> addDiscount(
    String name,
    String description,
    int value,
    String type,
  ) async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/discounts');
      final authData = await AuthLocalDataSource().getAuthData();
      final storeId = await AuthLocalDataSource().getStoreId();
      var response = await http.post(url, headers: {
        'Authorization': 'Bearer ${authData.token}',
        'Accept': 'application/json',
        'X-Store-Id': storeId.toString(),
      }, body: {
        'name': name,
        'description': description,
        'value': value.toString(),
        'type': type,
      });
      if (response.statusCode == 403) {
        response = await http.post(url, headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
        }, body: {
          'name': name,
          'description': description,
          'value': value.toString(),
          'type': type,
        });
      }

      if (response.statusCode == 201) {
        return const Right(true);
      } else {
        return Left('Failed to add discount (${response.statusCode})');
      }
    } catch (e) {
      return Left('Failed to add discount: $e');
    }
  }

  Future<Either<String, bool>> deleteDiscount(int id) async {
    try {
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/discounts/$id');
      final authData = await AuthLocalDataSource().getAuthData();
      final storeId = await AuthLocalDataSource().getStoreId();

      var response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${authData.token}',
          'Accept': 'application/json',
          'X-Store-Id': storeId.toString(),
        },
      );

      if (response.statusCode == 403) {
        response = await http.delete(
          url,
          headers: {
            'Authorization': 'Bearer ${authData.token}',
            'Accept': 'application/json',
          },
        );
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(true);
      }

      return Left('Failed to delete discount (${response.statusCode})');
    } catch (e) {
      return Left('Failed to delete discount: $e');
    }
  }
}
