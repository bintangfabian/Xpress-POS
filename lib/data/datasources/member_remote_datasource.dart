import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/member_response_model.dart';

class MemberRemoteDatasource {
  Future<Either<String, MemberResponseModel>> getMembers() async {
    try {
      final url = Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/members');
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
}

