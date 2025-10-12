import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:xpress/core/constants/variables.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/models/response/table_model.dart';

class TableRemoteDatasource {
  Future<Either<String, List<TableModel>>> getTables() async {
    try {
      final auth = await AuthLocalDataSource().getAuthData();
      final storeUuid = await AuthLocalDataSource().getStoreUuid();
      final url =
          Uri.parse('${Variables.baseUrl}/api/${Variables.apiVersion}/tables');
      final res = await http.get(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${auth.token}',
        if (storeUuid != null && storeUuid.isNotEmpty) 'X-Store-Id': storeUuid,
      });

      if (res.statusCode != 200) {
        return Left('Gagal memuat meja (${res.statusCode})');
      }

      final decoded = jsonDecode(res.body);
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

      final list = raw
          .whereType<Map<String, dynamic>>()
          .map(_mapServerToTableModel)
          .toList();
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

    return TableModel(
      id: asInt(m['id']),
      tableNumber: asString(m['table_number'], ''),
      name: asString(m['name'], ''),
      capacity: asInt(m['capacity']) ?? 4,
      isActive: asInt(m['is_active']) ?? 1,
      storeId: asString(m['store_id'], ''),
      startTime: asString(m['start_time'], DateTime.now().toIso8601String()),
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

        // Format table_number as T001, T002, etc.
        final tableNumber = 'T${number.toString().padLeft(3, '0')}';
        final tableName = 'Table $number';
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
}
