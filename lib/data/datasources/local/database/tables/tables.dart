import 'package:drift/drift.dart';

@DataClassName('DiningTable')
class Tables extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get status => text()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();
}
