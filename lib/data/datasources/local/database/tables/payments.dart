import 'package:drift/drift.dart';

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get uuid => text().unique()();
  TextColumn get orderUuid => text()();
  RealColumn get amount => real()();
  TextColumn get method => text()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
