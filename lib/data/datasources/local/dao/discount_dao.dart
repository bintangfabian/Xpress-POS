import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../database/database.dart';
import '../database/tables/discounts.dart';

part 'discount_dao.g.dart';

@DriftAccessor(tables: [Discounts])
class DiscountDao extends DatabaseAccessor<AppDatabase>
    with _$DiscountDaoMixin {
  DiscountDao(super.db);

  Future<List<Discount>> getAllDiscounts() {
    return (select(discounts)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  Future<List<Discount>> getActiveDiscounts() {
    final now = DateTime.now();
    return (select(discounts)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..where((tbl) => tbl.status.equals('active') | tbl.status.isNull())
          ..where((tbl) =>
              tbl.expiredDate.isNull() | tbl.expiredDate.isBiggerThanValue(now))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  Future<Discount?> getByUuid(String uuid) {
    return (select(discounts)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<Discount?> getByServerId(String serverId) {
    return (select(discounts)..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<void> insertOrUpdateDiscounts(
    List<DiscountsCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    // Use insertOnConflictUpdate for each entry to handle uuid unique constraint
    // insertOnConflictUpdate automatically uses unique constraints (uuid)
    for (final entry in entries) {
      try {
        await into(discounts).insertOnConflictUpdate(entry);
      } catch (e) {
        // If conflict still occurs, try to update existing record by uuid
        final uuid = entry.uuid.value;
        if (uuid.isNotEmpty) {
          final existing = await getByUuid(uuid);
          if (existing != null) {
            await (update(discounts)..where((tbl) => tbl.uuid.equals(uuid)))
                .write(entry);
          } else {
            // If no existing record, try insert without conflict
            await into(discounts).insert(entry);
          }
        }
      }
    }
  }

  Future<void> markAsSynced(
    String uuid, {
    String? serverId,
  }) async {
    await (update(discounts)..where((tbl) => tbl.uuid.equals(uuid))).write(
      DiscountsCompanion(
        syncStatus: const Value('synced'),
        serverId: serverId == null || serverId.isEmpty
            ? const Value.absent()
            : Value(serverId),
        updatedAt: Value(TimezoneHelper.now()),
      ),
    );
  }

  Future<void> clearAll() async {
    await delete(discounts).go();
  }
}
