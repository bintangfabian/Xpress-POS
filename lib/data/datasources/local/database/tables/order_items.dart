import 'package:drift/drift.dart';

class OrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderUuid => text()();
  TextColumn get productUuid => text()();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();
  RealColumn get cost => real()();
  TextColumn get optionsJson => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}
