import 'package:drift/drift.dart';

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get uuid => text().unique()();
  TextColumn get storeId => text()();
  IntColumn get userId => integer()();
  TextColumn get status => text()();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount =>
      real().withDefault(const Constant(0.0))();
  RealColumn get serviceCharge =>
      real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
}
