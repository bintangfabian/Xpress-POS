import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../database/database.dart';
import '../database/tables/payments.dart';

part 'payment_dao.g.dart';

@DriftAccessor(tables: [Payments])
class PaymentDao extends DatabaseAccessor<AppDatabase> with _$PaymentDaoMixin {
  PaymentDao(AppDatabase db) : super(db);

  Future<List<Payment>> getPendingPayments() {
    return (select(payments)..where((tbl) => tbl.syncStatus.equals('pending')))
        .get();
  }

  Future<void> markAsSynced(
    String uuid, {
    String? serverId,
  }) async {
    await (update(payments)..where((tbl) => tbl.uuid.equals(uuid))).write(
      PaymentsCompanion(
        syncStatus: const Value('synced'),
        serverId: serverId == null || serverId.isEmpty
            ? const Value.absent()
            : Value(serverId),
        updatedAt: Value(TimezoneHelper.now()),
      ),
    );
  }
}
