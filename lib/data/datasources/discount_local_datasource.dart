import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/datasources/local/dao/discount_dao.dart';
import 'package:xpress/data/datasources/local/database/database.dart';
import 'package:xpress/data/models/response/discount_response_model.dart'
    as remote;

class DiscountLocalDatasource {
  final DiscountDao _discountDao;

  DiscountLocalDatasource({DiscountDao? discountDao})
      : _discountDao = discountDao ?? DiscountDao(AppDatabase.instance);

  Future<List<remote.Discount>> getDiscounts() async {
    final discounts = await _discountDao.getAllDiscounts();
    return discounts.map((discount) {
      return remote.Discount(
        id: int.tryParse(discount.serverId ?? ''),
        name: discount.name,
        description: discount.description,
        type: discount.type,
        value: discount.value,
        status: discount.status,
        expiredDate: discount.expiredDate,
        createdAt: discount.updatedAt,
        updatedAt: discount.updatedAt,
      );
    }).toList();
  }

  Future<List<remote.Discount>> getActiveDiscounts() async {
    final discounts = await _discountDao.getActiveDiscounts();
    return discounts.map((discount) {
      return remote.Discount(
        id: int.tryParse(discount.serverId ?? ''),
        name: discount.name,
        description: discount.description,
        type: discount.type,
        value: discount.value,
        status: discount.status,
        expiredDate: discount.expiredDate,
        createdAt: discount.updatedAt,
        updatedAt: discount.updatedAt,
      );
    }).toList();
  }

  Future<void> saveDiscounts(List<remote.Discount> discounts) async {
    final companions = discounts.map((discount) {
      final serverId = discount.id?.toString() ?? '';
      final uuid = serverId.isNotEmpty
          ? 'discount-$serverId'
          : 'discount-${TimezoneHelper.now().microsecondsSinceEpoch}';

      return DiscountsCompanion.insert(
        uuid: uuid,
        name: discount.name ?? 'Unnamed Discount',
        description: discount.description == null
            ? const Value.absent()
            : Value(discount.description!),
        type: discount.type ?? 'percentage',
        value: discount.value ?? '0',
        status: discount.status == null
            ? const Value.absent()
            : Value(discount.status!),
        expiredDate: discount.expiredDate == null
            ? const Value.absent()
            : Value(discount.expiredDate!),
        serverId: serverId.isEmpty ? const Value.absent() : Value(serverId),
        syncStatus: const Value('synced'),
        updatedAt: Value(TimezoneHelper.now()),
        isDeleted: const Value(false),
      );
    }).toList();

    await _discountDao.insertOrUpdateDiscounts(companions);
  }

  Future<void> clearAll() async {
    await _discountDao.clearAll();
  }
}
