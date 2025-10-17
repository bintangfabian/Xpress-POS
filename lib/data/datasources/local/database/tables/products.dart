import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  RealColumn get cost => real()();
  RealColumn get price => real()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
}
