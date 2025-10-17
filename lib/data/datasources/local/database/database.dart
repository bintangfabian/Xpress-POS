import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'tables/order_items.dart';
import 'tables/orders.dart';
import 'tables/payments.dart';
import 'tables/products.dart';
import 'tables/stock_movements.dart';
import 'tables/tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Products,
    Orders,
    OrderItems,
    Payments,
    Tables,
    StockMovements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  factory AppDatabase() {
    return instance;
  }

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'xpress_app.db'));

    if (kReleaseMode) {
      return NativeDatabase.createInBackground(file);
    }

    return SqfliteQueryExecutor(path: file.path, singleInstance: true);
  });
}
