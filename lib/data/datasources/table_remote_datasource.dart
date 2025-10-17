import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

class TableRemoteDatasource {
  Future<Either<String, List<TableModel>>> getTables() async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      // Tambahkan per_page=1000 untuk mengambil semua meja
      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/tables?per_page=1000');
      final res = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      });

      if (res.statusCode != 200) {
        return Left('Gagal memuat meja (${res.statusCode})');
      }

      final decoded = jsonDecode(res.body);

      // Log raw response untuk debugging
      log('========================================');
      log('GET TABLES - Raw Response Type: ${decoded.runtimeType}');
      if (decoded is Map) {
        log('GET TABLES - Response Keys: ${decoded.keys.toList()}');
      }

      List<dynamic> raw = const [];
      if (decoded is List) {
        raw = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];
        if (data is List) {
          raw = data;
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) raw = data['data'];
          if (data['items'] is List) raw = data['items'];
          if (data['results'] is List) raw = data['results'];
        } else if (decoded['tables'] is List) {
          raw = decoded['tables'];
        }
      }

      // Log first item untuk melihat struktur data
      if (raw.isNotEmpty) {
        log('GET TABLES - First Item Raw Data:');
        log('${raw.first}');
      }

      final list = raw
          .whereType<Map<String, dynamic>>()
          .map(_mapServerToTableModel)
          .toList();

      // Urutkan berdasarkan table_number (sebagai integer)
      list.sort((a, b) {
        final aNum = int.tryParse(a.tableNumber ?? '0') ?? 0;
        final bNum = int.tryParse(b.tableNumber ?? '0') ?? 0;
        return aNum.compareTo(bNum);
      });

      // Log semua meja dengan ID-nya untuk debugging
      log('========================================');
      log('GET TABLES - Total: ${list.length} meja');
      for (final table in list) {
        log('MEJA: table_number="${table.tableNumber}", name="${table.name}", id=${table.id}, status=${table.status}');
      }
      log('========================================');

      return Right(list);
    } catch (e) {
      return Left('Tidak dapat memuat meja: $e');
    }
  }

  TableModel _mapServerToTableModel(Map<String, dynamic> m) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    String asString(dynamic v, [String d = '']) => v?.toString() ?? d;

    // ID is UUID string, not integer
    String? tableId = m['id']?.toString() ??
        m['table_id']?.toString() ??
        m['tableId']?.toString() ??
        m['_id']?.toString();

    // Log jika ID masih null untuk debugging
    if (tableId == null || tableId.isEmpty) {
      log('WARNING: Table ID is null/empty for table_number=${m['table_number']}');
      log('Available keys in data: ${m.keys.toList()}');
      log('Full data: $m');
    }

    return TableModel(
      id: tableId,
      tableNumber: asString(m['table_number'], ''),
      name: asString(m['name'], ''),
      capacity: asInt(m['capacity']) ?? 4,
      isActive: asInt(m['is_active']) ?? 1,
      storeId: asString(m['store_id'], ''),
      startTime:
          asString(m['start_time'], TimezoneHelper.now().toIso8601String()),
      status: asString(m['status'], 'available'),
      orderId: asInt(m['order_id']) ?? 0,
      paymentAmount: asInt(m['payment_amount']) ?? 0,
    );
  }

  Future<Either<String, bool>> addTables(int count) async {
    try {
      if (count <= 0) return const Right(true);
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      // Determine starting number from current tables
      final current = await getTables();
      int startFrom = 0;
      current.fold((_) {}, (list) {
        for (final t in list) {
          // Extract number from table_number (e.g., "T001" -> 1)
          final tableNum = t.tableNumber;
          if (tableNum != null && tableNum.isNotEmpty) {
            // Try to parse number from string like "T001" or direct number
            final numStr = tableNum.replaceAll(RegExp(r'[^0-9]'), '');
            final num = int.tryParse(numStr);
            if (num != null && num > startFrom) {
              startFrom = num;
            }
          }
        }
      });

      final url =
          Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/tables');
      final baseHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      for (int i = 1; i <= count; i++) {
        final number = startFrom + i;

        // Format table_number sebagai angka biasa: 1, 2, 3, dst
        final tableNumber = number.toString();
        final tableName = 'Meja $number';
        const defaultCapacity = 4;
        const isActive = 1;

        // Build request body with all required fields
        final jsonBody = {
          'table_number': tableNumber,
          'name': tableName,
          'capacity': defaultCapacity,
          'is_active': isActive,
          if (storeUuid != null && storeUuid.isNotEmpty) 'store_id': storeUuid,
        };

        final res = await http.post(
          url,
          headers: {
            ...baseHeaders,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(jsonBody),
        );

        if (res.statusCode != 200 && res.statusCode != 201) {
          final info = ' (${res.statusCode}) ${res.body}';
          return Left('Gagal membuat meja $tableName$info');
        }
      }
      return const Right(true);
    } catch (e) {
      return Left('Tidak dapat menambah meja: $e');
    }
  }

  // Update table status
  Future<Either<String, bool>> updateTableStatus({
    required String tableId, // Changed to String to support UUID
    required String status,
  }) async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();

      final url = Uri.parse(
          '${Variables.baseUrl}/api/${Variables.apiVersion}/tables/$tableId');

      final jsonBody = {
        'status': status,
      };

      log('========================================');
      log('UPDATE TABLE STATUS - START');
      log('UPDATE TABLE STATUS - URL: $url');
      log('UPDATE TABLE STATUS - Table ID (UUID): $tableId');
      log('UPDATE TABLE STATUS - New Status: $status');
      log('UPDATE TABLE STATUS - Body: ${jsonEncode(jsonBody)}');
      log('UPDATE TABLE STATUS - Store UUID: $storeUuid');
      log('UPDATE TABLE STATUS - Token: ${auth.token?.substring(0, 20)}...');

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      };

      log('UPDATE TABLE STATUS - Headers: $headers');

      // Tambahkan timeout 10 detik
      final res = await http
          .put(
        url,
        headers: headers,
        body: jsonEncode(jsonBody),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('UPDATE TABLE STATUS - TIMEOUT after 10 seconds');
          throw Exception(
              'Request timeout - server tidak merespon dalam 10 detik');
        },
      );

      log('UPDATE TABLE STATUS - Response Code: ${res.statusCode}');
      log('UPDATE TABLE STATUS - Response Body: ${res.body}');
      log('UPDATE TABLE STATUS - END');
      log('========================================');

      // Accept 200, 201, and 204 (No Content) as success
      if (res.statusCode >= 200 && res.statusCode < 300) {
        log('UPDATE TABLE STATUS - SUCCESS ✓');
        return const Right(true);
      }

      log('UPDATE TABLE STATUS - FAILED ✗');
      final info = ' (${res.statusCode}) ${res.body}';
      return Left('Gagal mengubah status meja$info');
    } catch (e, stackTrace) {
      log('UPDATE TABLE STATUS - ERROR ✗');
      log('UPDATE TABLE STATUS - Error: $e');
      log('UPDATE TABLE STATUS - StackTrace: $stackTrace');
      return Left('Tidak dapat mengubah status meja: $e');
    }
  }
}
