import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../database/database.dart';
import '../database/tables/categories.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Future<List<Category>> getAllCategories() {
    return (select(categories)
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  Future<Category?> getByUuid(String uuid) {
    return (select(categories)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<Category?> getByServerId(String serverId) {
    return (select(categories)..where((tbl) => tbl.serverId.equals(serverId)))
        .getSingleOrNull();
  }

  Future<void> insertOrUpdateCategories(
    List<CategoriesCompanion> entries,
  ) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(categories, entries);
    });
  }

  Future<void> markAsSynced(
    String uuid, {
    String? serverId,
  }) async {
    await (update(categories)..where((tbl) => tbl.uuid.equals(uuid))).write(
      CategoriesCompanion(
        syncStatus: const Value('synced'),
        serverId: serverId == null || serverId.isEmpty
            ? const Value.absent()
            : Value(serverId),
        updatedAt: Value(TimezoneHelper.now()),
      ),
    );
  }

  Future<void> clearAll() async {
    await delete(categories).go();
  }
}
