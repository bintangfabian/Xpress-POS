import 'package:drift/drift.dart';

class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get uuid => text().unique()();
  TextColumn get productUuid => text()();
  IntColumn get qtyChange => integer()();
  TextColumn get type => text()();
  RealColumn get unitCost => real().withDefault(const Constant(0.0))();
  TextColumn get reference => text().nullable()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
