import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/datasources/local/dao/category_dao.dart';
import 'package:xpress/data/datasources/local/database/database.dart';
import 'package:xpress/data/models/response/category_response_model.dart'
    as remote;

class CategoryLocalDatasource {
  final CategoryDao _categoryDao;

  CategoryLocalDatasource({CategoryDao? categoryDao})
      : _categoryDao = categoryDao ?? CategoryDao(AppDatabase.instance);

  Future<List<remote.CategoryModel>> getCategories() async {
    final categories = await _categoryDao.getAllCategories();
    return categories.map((category) {
      return remote.CategoryModel(
        id: int.tryParse(category.serverId ?? ''),
        name: category.name,
        image: category.image,
      );
    }).toList();
  }

  Future<void> saveCategories(List<remote.CategoryModel> categories) async {
    final companions = categories.map((category) {
      final serverId = category.id?.toString() ?? '';
      final uuid = serverId.isNotEmpty
          ? 'category-$serverId'
          : 'category-${TimezoneHelper.now().microsecondsSinceEpoch}';

      return CategoriesCompanion.insert(
        uuid: uuid,
        name: category.name ?? 'Unnamed Category',
        image: category.image == null
            ? const Value.absent()
            : Value(category.image!),
        serverId: serverId.isEmpty ? const Value.absent() : Value(serverId),
        syncStatus: const Value('synced'),
        updatedAt: Value(TimezoneHelper.now()),
        isDeleted: const Value(false),
      );
    }).toList();

    await _categoryDao.insertOrUpdateCategories(companions);
  }

  Future<void> clearAll() async {
    await _categoryDao.clearAll();
  }
}
