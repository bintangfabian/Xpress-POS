import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../database/database.dart';
import '../database/tables/products.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(AppDatabase db) : super(db);

  Future<List<Product>> getAllProducts() {
    return select(products).get();
  }

  Future<Product?> getByUuid(String uuid) {
    return (select(products)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<List<Product>> getPendingProducts() {
    return (select(products)..where((tbl) => tbl.syncStatus.equals('pending')))
        .get();
  }

  Future<void> insertOrUpdateProducts(
    List<ProductsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(products, entries);
    });
  }

  Future<void> markAsSynced(
    String uuid, {
    String? serverId,
  }) async {
    await (update(products)..where((tbl) => tbl.uuid.equals(uuid))).write(
      ProductsCompanion(
        syncStatus: const Value('synced'),
        serverId: serverId == null || serverId.isEmpty
            ? const Value.absent()
            : Value(serverId),
        updatedAt: Value(TimezoneHelper.now()),
      ),
    );
  }

  Future<void> clearAll() async {
    await delete(products).go();
  }
}
