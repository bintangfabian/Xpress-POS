import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../database/database.dart';
import '../database/tables/stock_movements.dart';

part 'stock_dao.g.dart';

@DriftAccessor(tables: [StockMovements])
class StockDao extends DatabaseAccessor<AppDatabase> with _$StockDaoMixin {
  StockDao(AppDatabase db) : super(db);

  Future<void> insertStockMovement(StockMovementsCompanion movement) async {
    await into(stockMovements).insertOnConflictUpdate(movement);
  }

  Future<List<StockMovement>> getAllMovements() {
    return select(stockMovements).get();
  }

  Future<List<StockMovement>> getPendingMovements() {
    return (select(stockMovements)
          ..where((tbl) => tbl.syncStatus.equals('pending')))
        .get();
  }

  Future<void> markAsSynced(
    String uuid, {
    String? serverId,
  }) async {
    await (update(stockMovements)..where((tbl) => tbl.uuid.equals(uuid))).write(
      StockMovementsCompanion(
        syncStatus: const Value('synced'),
        serverId: serverId == null || serverId.isEmpty
            ? const Value.absent()
            : Value(serverId),
        updatedAt: Value(TimezoneHelper.now()),
      ),
    );
  }
}
