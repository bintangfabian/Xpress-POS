import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/store_local_datasource.dart';
import 'package:xpress/data/models/response/store_response_model.dart';

class StoreRemoteDatasource {
  Future<Either<String, StoreDetail>> getCurrentStore() async {
    try {
      final url = Uri.parse(
        '${Variables.baseUrl}/api/${Variables.apiVersion}/stores/current',
      );
      final ds = AuthLocalDataSource();
      final auth = await ds.getAuthData();
      final storeUuid = await ds.getStoreUuid();
      final storeId = await ds.getStoreId();

      final headers = <String, String>{
        'Authorization': 'Bearer ${auth.token}',
        'Accept': 'application/json',
      };

      if (storeUuid != null && storeUuid.isNotEmpty) {
        headers['X-Store-Id'] = storeUuid;
      } else if (storeId != 0) {
        headers['X-Store-Id'] = storeId.toString();
      }

      var response = await http.get(url, headers: headers);

      if (response.statusCode == 403 && headers.containsKey('X-Store-Id')) {
        headers.remove('X-Store-Id');
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200) {
        final parsed = StoreDetailResponseModel.fromJson(response.body);
        final detail = parsed.data;
        if (detail != null) {
          // Save store detail to local storage for receipt printing
          final storeLocalDatasource = StoreLocalDatasource();
          await storeLocalDatasource.saveStoreDetail(detail);
          return Right(detail);
        }
        return const Left('Store detail not found in response');
      }

      return Left(
        'Failed to fetch store detail (${response.statusCode})',
      );
    } catch (e) {
      return Left('Failed to fetch store detail: $e');
    }
  }
}
