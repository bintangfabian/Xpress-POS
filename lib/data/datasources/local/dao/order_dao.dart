import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../database/database.dart';
import '../database/tables/order_items.dart';
import '../database/tables/orders.dart';

part 'order_dao.g.dart';

@DriftAccessor(tables: [Orders, OrderItems])
class OrderDao extends DatabaseAccessor<AppDatabase> with _$OrderDaoMixin {
  OrderDao(super.db);

  Future<List<Order>> getAllOrders() {
    return select(orders).get();
  }

  Future<List<Order>> getPendingOrders() {
    return (select(orders)..where((tbl) => tbl.syncStatus.equals('pending')))
        .get();
  }

  Future<List<Order>> getOrdersByDateRange(
      DateTime startDate, DateTime endDate) {
    return (select(orders)
          ..where((tbl) =>
              tbl.updatedAt.isBiggerOrEqualValue(startDate) &
              tbl.updatedAt.isSmallerOrEqualValue(endDate) &
              tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
        .get();
  }

  Future<void> insertOrder(OrdersCompanion order) async {
    await into(orders).insertOnConflictUpdate(order);
  }

  Future<void> insertOrderItems(List<OrderItemsCompanion> items) async {
    if (items.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(orderItems, items);
    });
  }

  Future<List<OrderItem>> getItemsByOrder(String orderUuid) {
    return (select(orderItems)..where((tbl) => tbl.orderUuid.equals(orderUuid)))
        .get();
  }

  Future<List<OrderItem>> getItemsForOrders(List<String> orderUuids) {
    if (orderUuids.isEmpty) {
      return Future.value(const []);
    }
    return (select(orderItems)..where((tbl) => tbl.orderUuid.isIn(orderUuids)))
        .get();
  }

  Future<void> updateSyncStatus(String uuid, String status) async {
    await (update(orders)..where((tbl) => tbl.uuid.equals(uuid))).write(
      OrdersCompanion(
        syncStatus: Value(status),
        updatedAt: Value(TimezoneHelper.now()),
      ),
    );
  }

  Future<void> markAsSynced(
    String uuid, {
    String? serverId,
  }) async {
    await (update(orders)..where((tbl) => tbl.uuid.equals(uuid))).write(
      OrdersCompanion(
        syncStatus: const Value('synced'),
        serverId: serverId == null || serverId.isEmpty
            ? const Value.absent()
            : Value(serverId),
        updatedAt: Value(TimezoneHelper.now()),
      ),
    );
  }
}
