import 'package:drift/drift.dart';

class Discounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // 'percentage' or 'fixed'
  TextColumn get value => text()(); // Discount value
  TextColumn get status => text().nullable()();
  DateTimeColumn get expiredDate => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}
