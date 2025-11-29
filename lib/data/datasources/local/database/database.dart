import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'tables/categories.dart';
import 'tables/discounts.dart';
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
    Categories,
    Discounts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  factory AppDatabase() {
    return instance;
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          // Add Categories table
          await migrator.createTable(this.categories);
          // Add Discounts table
          await migrator.createTable(this.discounts);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'xpress_app.db'));

    // Always use SqfliteQueryExecutor for better compatibility
    // NativeDatabase requires SQLite native library which may not be available
    return SqfliteQueryExecutor(path: file.path, singleInstance: true);
  });
}
