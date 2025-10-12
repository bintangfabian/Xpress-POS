import 'dart:convert';
import 'dart:developer';

import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/qris_response_model.dart';
import 'package:xpress/data/models/response/qris_status_response_model.dart';
import 'package:http/http.dart' as http;

class MidtransRemoteDatasource {
  String generateBasicAuthHeader(String serverKey) {
    final base64Credentials = base64Encode(utf8.encode('$serverKey:'));
    final authHeader = 'Basic $base64Credentials';

    return authHeader;
  }

  Future<QrisResponseModel> generateQRCode(
      String orderId, int grossAmount) async {
    final serverKey = await AuthLocalDataSource().getMitransServerKey();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(serverKey),
    };

    final body = jsonEncode({
      'payment_type': 'gopay',
      'transaction_details': {
        'gross_amount': grossAmount,
        'order_id': orderId,
      },
    });

    final response = await http.post(
      Uri.parse('https://api.midtrans.com/v2/charge'),
      // Uri.parse('https://api.sandbox.midtrans.com/v2/charge'),

      headers: headers,
      body: body,
    );

    log("StatusCode: ${response.statusCode}");
    log("Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return QrisResponseModel.fromJson(response.body);
    } else {
      throw Exception('Failed to generate QR Code');
    }
  }

  Future<QrisStatusResponseModel> checkPaymentStatus(String orderId) async {
    final serverKey = await AuthLocalDataSource().getMitransServerKey();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': generateBasicAuthHeader(serverKey),
    };

    final response = await http.get(
      Uri.parse('https://api.midtrans.com/v2/$orderId/status'),
      // Uri.parse('https://api.sandbox.midtrans.com/v2/$orderId/status'),
      headers: headers,
    );
    log("StatusCode: ${response.statusCode}");
    log("Body: ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      return QrisStatusResponseModel.fromJson(response.body);
    } else {
      throw Exception('Failed to check payment status');
    }
  }
}
