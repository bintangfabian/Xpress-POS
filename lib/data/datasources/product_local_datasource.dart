import 'dart:developer';

import 'package:xpress/data/models/response/product_response_model.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:xpress/presentation/home/models/order_model.dart';
import 'package:xpress/presentation/table/models/draft_order_item.dart';
import 'package:xpress/presentation/table/models/draft_order_model.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../presentation/home/models/product_quantity.dart';

class ProductLocalDatasource {
  ProductLocalDatasource._init();

  static final ProductLocalDatasource instance = ProductLocalDatasource._init();

  final String tableProduct = 'products';
  final String tableOrder = 'orders';
  final String tableOrderItem = 'order_items';
  final String tableManagement = 'table_management';

  static Database? _database;

  // "id": 1,
  //           "category_id": 1,
  //           "name": "Mie Ayam",
  //           "description": "Ipsa dolorem impedit dolor. Libero nisi quidem expedita quod mollitia ad. Voluptas ut quia nemo nisi odit fuga. Fugit autem qui ratione laborum eum.",
  //           "image": "https://via.placeholder.com/640x480.png/002200?text=nihil",
  //           "price": "2000.44",
  //           "stock": 94,
  //           "status": 1,
  //           "is_favorite": 1,
  //           "created_at": "2024-02-08T14:30:22.000000Z",
  //           "updated_at": "2024-02-08T15:14:22.000000Z"

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns to existing products table
      await db.execute('''
        ALTER TABLE $tableProduct ADD COLUMN minStockLevel INTEGER DEFAULT 0
      ''');
      await db.execute('''
        ALTER TABLE $tableProduct ADD COLUMN trackInventory INTEGER DEFAULT 0
      ''');
    }
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableProduct (
        id INTEGER PRIMARY KEY,
        product_id INTEGER,
        name TEXT,
        categoryId INTEGER,
        categoryName TEXT,
        description TEXT,
        image TEXT,
        price TEXT,
        stock INTEGER,
        minStockLevel INTEGER DEFAULT 0,
        trackInventory INTEGER DEFAULT 0,
        status INTEGER,
        isFavorite INTEGER,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrder (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_amount INTEGER,
        sub_total INTEGER,
        tax INTEGER,
        discount INTEGER,
        discount_amount INTEGER,
        service_charge INTEGER,
        total INTEGER,
        payment_method TEXT,
        total_item INTEGER,
        id_kasir INTEGER,
        nama_kasir TEXT,
        transaction_time TEXT,
        table_number INTEGER,
        customer_name TEXT,
        status TEXT,
        payment_status TEXT,
        is_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableOrderItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');

    await db.execute('''
        CREATE TABLE $tableManagement (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_number INTEGER,
        start_time Text,
        order_id INTEGER,
        payment_amount INTEGER,
        status TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE draft_orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_item INTEGER,
        subtotal INTEGER,
        tax INTEGER,
        discount INTEGER,
        discount_amount INTEGER,
        service_charge INTEGER,
        total INTEGER,
        transaction_time TEXT,
        table_number INTEGER,
        draft_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE draft_order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_draft_order INTEGER,
        id_product INTEGER,
        quantity INTEGER,
        price INTEGER
      )
    ''');
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dbresto30.db');
    return _database!;
  }

  //save order
  Future<int> saveOrder(OrderModel order) async {
    log("OrderModel:  ${order.toMap()}");

    final db = await instance.database;
    int id = await db.insert(tableOrder, order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    for (var item in order.orderItems) {
      log("Item: ${item.toLocalMap(id)}");
      await db.insert(tableOrderItem, item.toLocalMap(id),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    log("Success Order: ${order.toMap()}");
    return id;
  }

  //get data order
  Future<List<OrderModel>> getOrderByIsNotSync() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query(tableOrder, where: 'is_sync = ?', whereArgs: [0]);
    return List.generate(maps.length, (i) {
      return OrderModel.fromMap(maps[i]);
    });
  }

  Future<List<OrderModel>> getAllOrder(
    DateTime date,
  ) async {
    final db = await instance.database;
    //date to iso8601
    final dateIso = date.toIso8601String();
    //get yyyy-MM-dd
    final dateYYYYMMDD = dateIso.substring(0, 10);
    // final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final List<Map<String, dynamic>> maps = await db.query(
      tableOrder,
      where: 'transaction_time like ?',
      whereArgs: ['$dateYYYYMMDD%'],
      // where: 'transaction_time BETWEEN ? AND ?',
      // whereArgs: [
      //   DateFormat.yMd().format(start),
      //   DateFormat.yMd().format(end)
      // ],
    );
    return List.generate(maps.length, (i) {
      log("OrderModel: ${OrderModel.fromMap(maps[i])}");
      return OrderModel.fromMap(maps[i]);
    });
  }

  //get order item by order id
  Future<List<ProductQuantity>> getOrderItemByOrderId(int orderId) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db
        .query(tableOrderItem, where: 'id_order = ?', whereArgs: [orderId]);
    return List.generate(maps.length, (i) {
      log("ProductQuantity: ${ProductQuantity.fromLocalMap(maps[i])}");
      return ProductQuantity.fromLocalMap(maps[i]);
    });
  }

  //update payment status by order id
  Future<void> updatePaymentStatus(
      int orderId, String paymentStatus, String status) async {
    final db = await instance.database;
    await db.update(
        tableOrder, {'payment_status': paymentStatus, 'status': status},
        where: 'id = ?', whereArgs: [orderId]);
    log('update payment status success | order id: $orderId | payment status: $paymentStatus | status: $status');
  }

  //update order is sync
  Future<void> updateOrderIsSync(int orderId) async {
    final db = await instance.database;
    await db.update(tableOrder, {'is_sync': 1},
        where: 'id = ?', whereArgs: [orderId]);
  }

  //insert data product
  Future<void> insertProduct(Product product) async {
    log("Product: ${product.toMap()}");
    final db = await instance.database;
    await db.insert(tableProduct, product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  //insert list of product
  Future<void> insertProducts(List<Product> products) async {
    final db = await instance.database;
    for (var product in products) {
      await db.insert(tableProduct, product.toLocalMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print(
          'inserted success id: ${product.productId} | name: ${product.name} | price: ${product.price}');
    }
  }

  //get all products
  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableProduct);
    return List.generate(maps.length, (i) {
      return Product.fromLocalMap(maps[i]);
    });
  }

  Future<Product?> getProductById(int id) async {
    final db = await instance.database;
    final result =
        await db.query(tableProduct, where: 'product_id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return Product.fromMap(result.first);
  }

  // get Last Table Management

  Future<TableModel?> getLastTableManagement() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps =
        await db.query(tableManagement, orderBy: 'id DESC', limit: 1);
    if (maps.isEmpty) {
      return null;
    }
    return TableModel.fromMap(maps[0]);
  }

  // generate table managent with count
  Future<void> generateTableManagement(int count) async {
    final db = await instance.database;
    TableModel? lastTable = await getLastTableManagement();

    // Parse tableNumber from String to int for calculation
    int lastTableNumber = 0;
    if (lastTable?.tableNumber != null && lastTable!.tableNumber!.isNotEmpty) {
      // Extract number from string like "T001" -> 1
      final numStr = lastTable.tableNumber!.replaceAll(RegExp(r'[^0-9]'), '');
      lastTableNumber = int.tryParse(numStr) ?? 0;
    }

    for (int i = 1; i <= count; i++) {
      lastTableNumber++;

      // Format table number as T001, T002, etc.
      final tableNumber = 'T${lastTableNumber.toString().padLeft(3, '0')}';
      final tableName = 'Table $lastTableNumber';

      TableModel newTable = TableModel(
        tableNumber: tableNumber,
        name: tableName,
        capacity: 4,
        isActive: 1,
        status: 'available',
        orderId: 0,
        paymentAmount: 0,
        startTime: DateTime.now().toIso8601String(),
      );
      await db.insert(
        tableManagement,
        newTable.toMap(),
      );
    }
  }

  // get all table
  Future<List<TableModel>> getAllTable() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(tableManagement);
    log("Table Management: $maps");
    return List.generate(maps.length, (i) {
      return TableModel.fromMap(maps[i]);
    });
  }

  // get last order where table number
  Future<OrderModel?> getLastOrderTable(int tableNumber) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableOrder,
      where: 'table_number = ?',
      whereArgs: [tableNumber],
      orderBy: 'id DESC', // Urutkan berdasarkan id dari yang terbesar (terbaru)
      limit: 1, // Ambil hanya satu data terakhir
    );

    if (maps.isEmpty) {
      return null;
    }

    return OrderModel.fromMap(maps[0]);
  }

  // get table by status
  Future<List<TableModel>> getTableByStatus(String status) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableManagement,
      where: 'status = ?',
      whereArgs: [status],
    );

    return List.generate(maps.length, (i) {
      return TableModel.fromMap(maps[i]);
    });
  }

  // update status tabel
  Future<void> updateStatusTable(TableModel table) async {
    log("Table: ${table.toMap()}");
    final db = await instance.database;
    await db.update(tableManagement, table.toMap(),
        where: 'id = ?', whereArgs: [table.id]);
    log("Success Update Status Table: ${table.toMap()}");
  }

  //delete all products
  Future<void> deleteAllProducts() async {
    final db = await instance.database;
    await db.delete(tableProduct);
  }

  Future<int> saveDraftOrder(DraftOrderModel order) async {
    log("save draft order: ${order.toMapForLocal()}");
    final db = await instance.database;
    int id = await db.insert('draft_orders', order.toMapForLocal());
    log("draft order id: $id | ${order.discountAmount}");
    for (var orderItem in order.orders) {
      await db.insert('draft_order_items', orderItem.toMapForLocal(id));
      log("draft order item  ${orderItem.toMapForLocal(id)}");
    }

    return id;
  }

  //get all draft order
  Future<List<DraftOrderModel>> getAllDraftOrder() async {
    final db = await instance.database;
    final result = await db.query('draft_orders', orderBy: 'id ASC');

    List<DraftOrderModel> results = await Future.wait(result.map((item) async {
      // Your asynchronous operation here
      final draftOrderItem =
          await getDraftOrderItemByOrderId(item['id'] as int);
      return DraftOrderModel.newFromLocalMap(item, draftOrderItem);
    }));
    return results;
  }

  // get Darft Order by id
  Future<DraftOrderModel?> getDraftOrderById(int id) async {
    final db = await instance.database;
    final result =
        await db.query('draft_orders', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    final draftOrderItem =
        await getDraftOrderItemByOrderId(result.first['id'] as int);
    log("draft order item: $draftOrderItem | ${result.first.toString()}");
    return DraftOrderModel.newFromLocalMap(result.first, draftOrderItem);
  }

  //get draft order item by id order
  Future<List<DraftOrderItem>> getDraftOrderItemByOrderId(int idOrder) async {
    final db = await instance.database;
    final result =
        await db.query('draft_order_items', where: 'id_draft_order = $idOrder');

    List<DraftOrderItem> results = await Future.wait(result.map((item) async {
      // Your asynchronous operation here
      final product = await getProductById(item['id_product'] as int);
      return DraftOrderItem(
          product: product!, quantity: item['quantity'] as int);
    }));
    return results;
  }

  //remove draft order by id
  Future<void> removeDraftOrderById(int id) async {
    final db = await instance.database;
    await db.delete('draft_orders', where: 'id = ?', whereArgs: [id]);
    await db.delete('draft_order_items',
        where: 'id_draft_order = ?', whereArgs: [id]);
  }
}
