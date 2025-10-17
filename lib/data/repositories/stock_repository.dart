import 'dart:math';

import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../datasources/local/dao/stock_dao.dart';
import '../datasources/local/database/database.dart';

class StockRepository {
  StockRepository({
    required AppDatabase database,
  }) : _stockDao = StockDao(database);

  final StockDao _stockDao;
  final Random _random = Random();

  Future<void> recordStockChange(
    String productUuid,
    int qtyChange,
    double unitCost,
    String type, {
    String? reference,
  }) async {
    final movement = StockMovementsCompanion.insert(
      uuid: _generateUuid(),
      productUuid: productUuid,
      qtyChange: qtyChange,
      type: type,
      unitCost: Value(unitCost),
      reference: reference == null ? const Value.absent() : Value(reference),
      syncStatus: const Value('pending'),
      updatedAt: Value(TimezoneHelper.now()),
    );

    await _stockDao.insertStockMovement(movement);
  }

  Future<List<StockMovement>> getAllMovements() {
    return _stockDao.getAllMovements();
  }

  String _generateUuid() {
    final timestamp = TimezoneHelper.now().microsecondsSinceEpoch;
    final randomPart = _random.nextInt(1 << 32);
    return 'stock-$timestamp-$randomPart';
  }
}
