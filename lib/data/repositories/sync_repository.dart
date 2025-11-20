import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

import '../datasources/local/dao/category_dao.dart';
import '../datasources/local/dao/discount_dao.dart';
import '../datasources/local/dao/order_dao.dart';
import '../datasources/local/dao/payment_dao.dart';
import '../datasources/local/dao/product_dao.dart';
import '../datasources/local/dao/stock_dao.dart';
import '../datasources/local/database/database.dart';
import '../services/api_service.dart';

class SyncRepository {
  SyncRepository({
    required AppDatabase database,
    required ApiService apiService,
    required OnlineCheckerBloc onlineCheckerBloc,
    ProductDao? productDao,
    OrderDao? orderDao,
    PaymentDao? paymentDao,
    StockDao? stockDao,
    CategoryDao? categoryDao,
    DiscountDao? discountDao,
    Box<dynamic>? settingsBox,
  })  : _database = database,
        _apiService = apiService,
        _onlineCheckerBloc = onlineCheckerBloc,
        _productDao = productDao ?? ProductDao(database),
        _orderDao = orderDao ?? OrderDao(database),
        _paymentDao = paymentDao ?? PaymentDao(database),
        _stockDao = stockDao ?? StockDao(database),
        _categoryDao = categoryDao ?? CategoryDao(database),
        _discountDao = discountDao ?? DiscountDao(database),
        _settingsBox = settingsBox ?? Hive.box('settings');

  final AppDatabase _database;
  final ApiService _apiService;
  final OnlineCheckerBloc _onlineCheckerBloc;
  final ProductDao _productDao;
  final OrderDao _orderDao;
  final PaymentDao _paymentDao;
  final StockDao _stockDao;
  final CategoryDao _categoryDao;
  final DiscountDao _discountDao;
  final Box<dynamic> _settingsBox;

  static const _lastSyncKey = 'lastSync';
  bool _isSyncing = false;

  Future<void> runFullSync() async {
    if (_isSyncing) {
      throw SyncException('Sinkronisasi sedang berjalan');
    }

    if (!_onlineCheckerBloc.isOnline) {
      throw SyncException('Tidak dapat sinkronisasi saat offline.');
    }

    _isSyncing = true;
    try {
      await uploadPending();
      final lastSync = _readLastSync();
      await downloadSince(lastSync);
      await _settingsBox.put(
        _lastSyncKey,
        TimezoneHelper.now().toIso8601String(),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> uploadPending() async {
    if (!_onlineCheckerBloc.isOnline) {
      return;
    }

    final pendingOrders = await _orderDao.getPendingOrders();
    final pendingOrderUuids = pendingOrders.map((order) => order.uuid).toList();
    final pendingOrderItems =
        await _orderDao.getItemsForOrders(pendingOrderUuids);
    final pendingPayments = await _paymentDao.getPendingPayments();
    final pendingMovements = await _stockDao.getPendingMovements();
    final pendingProducts = await _productDao.getPendingProducts();

    final hasChanges = pendingOrders.isNotEmpty ||
        pendingPayments.isNotEmpty ||
        pendingMovements.isNotEmpty ||
        pendingProducts.isNotEmpty;

    if (!hasChanges) {
      return;
    }

    final payload = <String, dynamic>{
      'orders': pendingOrders.map((order) => order.toJson()).toList(),
      'order_items': pendingOrderItems.map((item) => item.toJson()).toList(),
      'payments': pendingPayments.map((payment) => payment.toJson()).toList(),
      'stock_movements':
          pendingMovements.map((movement) => movement.toJson()).toList(),
      'products': pendingProducts.map((product) => product.toJson()).toList(),
    };

    final response = await _apiService.syncUpload(payload);

    if (!response.success) {
      throw SyncException(response.message ?? 'Gagal mengunggah data.');
    }

    final responseData = response.data is Map<String, dynamic>
        ? response.data
        : <String, dynamic>{};
    await _database.transaction(() async {
      for (final order in pendingOrders) {
        final serverId = _lookupServerId(responseData, 'orders', order.uuid);
        await _orderDao.markAsSynced(order.uuid, serverId: serverId);
      }

      for (final payment in pendingPayments) {
        final serverId =
            _lookupServerId(responseData, 'payments', payment.uuid);
        await _paymentDao.markAsSynced(payment.uuid, serverId: serverId);
      }

      for (final movement in pendingMovements) {
        final serverId =
            _lookupServerId(responseData, 'stock_movements', movement.uuid);
        await _stockDao.markAsSynced(movement.uuid, serverId: serverId);
      }

      for (final product in pendingProducts) {
        final serverId =
            _lookupServerId(responseData, 'products', product.uuid);
        await _productDao.markAsSynced(product.uuid, serverId: serverId);
      }
    });
  }

  Future<void> downloadSince(DateTime? lastSync) async {
    if (!_onlineCheckerBloc.isOnline) {
      return;
    }

    final since = lastSync ??
        TimezoneHelper.toWib(
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        );
    final response = await _apiService.syncDownload(since);

    if (!response.success) {
      throw SyncException(response.message ?? 'Gagal mengambil data.');
    }

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      return;
    }

    final orders = _castList(data['orders']);
    final products = _castList(data['products']);
    final stockMovements = _castList(data['stock_movements']);
    final categories = _castList(data['categories']);
    final discounts = _castList(data['discounts']);

    await _database.transaction(() async {
      for (final order in orders) {
        await _applyRemoteOrder(order);
      }

      for (final product in products) {
        await _applyRemoteProduct(product);
      }

      for (final movement in stockMovements) {
        await _applyRemoteStockMovement(movement);
      }

      for (final category in categories) {
        await _applyRemoteCategory(category);
      }

      for (final discount in discounts) {
        await _applyRemoteDiscount(discount);
      }
    });
  }

  Future<void> _applyRemoteOrder(Map<String, dynamic> data) async {
    final uuid = _readString(data, 'uuid');
    if (uuid == null || uuid.isEmpty) return;

    final incomingUpdatedAt =
        _parseDate(data['updatedAt'] ?? data['updated_at']);
    final existing = await (_database.select(_database.orders)
          ..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();

    if (existing != null &&
        incomingUpdatedAt != null &&
        !incomingUpdatedAt.isAfter(existing.updatedAt)) {
      return;
    }

    final isDeleted = _readBool(data, 'isDeleted') ?? false;

    final storeId = _readString(data, 'storeId') ?? existing?.storeId;
    final userId = _readInt(data, 'userId') ?? existing?.userId;
    final status = _readString(data, 'status') ?? existing?.status;

    if ((storeId == null || userId == null || status == null) &&
        existing == null) {
      return;
    }

    if (isDeleted) {
      await (_database.update(_database.orders)
            ..where((tbl) => tbl.uuid.equals(uuid)))
          .write(
        OrdersCompanion(
          isDeleted: const Value(true),
          syncStatus: const Value('synced'),
          updatedAt: Value(incomingUpdatedAt ?? TimezoneHelper.now()),
        ),
      );
      return;
    }

    final subtotal = _readDouble(data, 'subtotal') ?? existing?.subtotal ?? 0;
    final discountAmount =
        _readDouble(data, 'discountAmount') ?? existing?.discountAmount ?? 0;
    final serviceCharge =
        _readDouble(data, 'serviceCharge') ?? existing?.serviceCharge ?? 0;
    final total = _readDouble(data, 'total') ?? existing?.total ?? 0;
    final paymentMethod =
        _readString(data, 'paymentMethod') ?? existing?.paymentMethod;
    final notes = _readString(data, 'notes') ?? existing?.notes;
    final serverId = _readString(data, 'serverId') ?? existing?.serverId;

    final companion = OrdersCompanion(
      uuid: Value(uuid),
      storeId: Value(storeId ?? existing?.storeId ?? ''),
      userId: Value(userId ?? existing?.userId ?? 0),
      status: Value(status ?? existing?.status ?? ''),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      serviceCharge: Value(serviceCharge),
      total: Value(total),
      paymentMethod:
          paymentMethod == null ? const Value.absent() : Value(paymentMethod),
      notes: notes == null ? const Value.absent() : Value(notes),
      syncStatus: const Value('synced'),
      serverId: serverId == null ? const Value.absent() : Value(serverId),
      updatedAt: Value(incomingUpdatedAt ?? TimezoneHelper.now()),
      isDeleted: Value(isDeleted),
    );

    await _database.into(_database.orders).insertOnConflictUpdate(companion);
  }

  Future<void> _applyRemoteProduct(Map<String, dynamic> data) async {
    final uuid = _readString(data, 'uuid');
    if (uuid == null || uuid.isEmpty) return;

    final incomingUpdatedAt =
        _parseDate(data['updatedAt'] ?? data['updated_at']);
    final existing = await (_database.select(_database.products)
          ..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();

    if (existing != null &&
        incomingUpdatedAt != null &&
        !incomingUpdatedAt.isAfter(existing.updatedAt)) {
      return;
    }

    final isDeleted = _readBool(data, 'isDeleted') ?? false;
    final serverId = _readString(data, 'serverId') ?? existing?.serverId;
    final name = _readString(data, 'name') ?? existing?.name;
    final cost = _readDouble(data, 'cost') ?? existing?.cost ?? 0;
    final price = _readDouble(data, 'price') ?? existing?.price ?? 0;
    final stock = _readInt(data, 'stock') ?? existing?.stock ?? 0;

    if (name == null && existing == null) {
      return;
    }

    final companion = ProductsCompanion(
      uuid: Value(uuid),
      serverId: serverId == null ? const Value.absent() : Value(serverId),
      name: Value(name ?? existing?.name ?? ''),
      cost: Value(cost),
      price: Value(price),
      stock: Value(stock),
      syncStatus: const Value('synced'),
      updatedAt: Value(incomingUpdatedAt ?? TimezoneHelper.now()),
      isDeleted: Value(isDeleted),
    );

    await _database.into(_database.products).insertOnConflictUpdate(companion);
  }

  Future<void> _applyRemoteStockMovement(Map<String, dynamic> data) async {
    final uuid = _readString(data, 'uuid');
    if (uuid == null || uuid.isEmpty) return;

    final incomingUpdatedAt =
        _parseDate(data['updatedAt'] ?? data['updated_at']);
    final existing = await (_database.select(_database.stockMovements)
          ..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();

    if (existing != null &&
        incomingUpdatedAt != null &&
        !incomingUpdatedAt.isAfter(existing.updatedAt)) {
      return;
    }

    final serverId = _readString(data, 'serverId') ?? existing?.serverId;
    final productUuid =
        _readString(data, 'productUuid') ?? existing?.productUuid;
    final qtyChange = _readInt(data, 'qtyChange') ?? existing?.qtyChange ?? 0;
    final type = _readString(data, 'type') ?? existing?.type;
    final unitCost = _readDouble(data, 'unitCost') ?? existing?.unitCost ?? 0;
    final reference = _readString(data, 'reference') ?? existing?.reference;

    if ((productUuid == null || type == null) && existing == null) {
      return;
    }

    final companion = StockMovementsCompanion(
      uuid: Value(uuid),
      serverId: serverId == null ? const Value.absent() : Value(serverId),
      productUuid: Value(productUuid ?? existing?.productUuid ?? ''),
      qtyChange: Value(qtyChange),
      type: Value(type ?? existing?.type ?? ''),
      unitCost: Value(unitCost),
      reference: reference == null ? const Value.absent() : Value(reference),
      syncStatus: const Value('synced'),
      updatedAt: Value(incomingUpdatedAt ?? TimezoneHelper.now()),
    );

    await _database
        .into(_database.stockMovements)
        .insertOnConflictUpdate(companion);
  }

  Future<void> _applyRemoteCategory(Map<String, dynamic> data) async {
    final uuid = _readString(data, 'uuid');
    if (uuid == null || uuid.isEmpty) {
      // Generate UUID from server ID if available
      final serverId =
          _readString(data, 'serverId') ?? _readString(data, 'id')?.toString();
      if (serverId == null || serverId.isEmpty) return;
      final generatedUuid = 'category-$serverId';
      final existing = await _categoryDao.getByUuid(generatedUuid);
      if (existing != null) return; // Already exists
    }

    final incomingUpdatedAt =
        _parseDate(data['updatedAt'] ?? data['updated_at']);
    final existingUuid = uuid ??
        'category-${_readString(data, 'serverId') ?? _readString(data, 'id')?.toString() ?? ''}';
    final existing = await _categoryDao.getByUuid(existingUuid);

    if (existing != null &&
        incomingUpdatedAt != null &&
        !incomingUpdatedAt.isAfter(existing.updatedAt)) {
      return;
    }

    final serverId =
        _readString(data, 'serverId') ?? _readString(data, 'id')?.toString();
    final name = _readString(data, 'name') ?? existing?.name;
    final image = _readString(data, 'image') ?? existing?.image;
    final isDeleted = _readBool(data, 'isDeleted') ?? false;

    if (name == null && existing == null) {
      return;
    }

    final finalUuid = uuid ?? existingUuid;
    final companion = CategoriesCompanion(
      uuid: Value(finalUuid),
      serverId: serverId == null || serverId.isEmpty
          ? const Value.absent()
          : Value(serverId),
      name: Value(name ?? existing?.name ?? ''),
      image: image == null ? const Value.absent() : Value(image),
      syncStatus: const Value('synced'),
      updatedAt: Value(incomingUpdatedAt ?? TimezoneHelper.now()),
      isDeleted: Value(isDeleted),
    );

    await _database
        .into(_database.categories)
        .insertOnConflictUpdate(companion);
  }

  Future<void> _applyRemoteDiscount(Map<String, dynamic> data) async {
    final uuid = _readString(data, 'uuid');
    if (uuid == null || uuid.isEmpty) {
      final serverId =
          _readString(data, 'serverId') ?? _readString(data, 'id')?.toString();
      if (serverId == null || serverId.isEmpty) return;
      final generatedUuid = 'discount-$serverId';
      final existing = await _discountDao.getByUuid(generatedUuid);
      if (existing != null) return;
    }

    final incomingUpdatedAt =
        _parseDate(data['updatedAt'] ?? data['updated_at']);
    final existingUuid = uuid ??
        'discount-${_readString(data, 'serverId') ?? _readString(data, 'id')?.toString() ?? ''}';
    final existing = await _discountDao.getByUuid(existingUuid);

    if (existing != null &&
        incomingUpdatedAt != null &&
        !incomingUpdatedAt.isAfter(existing.updatedAt)) {
      return;
    }

    final serverId =
        _readString(data, 'serverId') ?? _readString(data, 'id')?.toString();
    final name = _readString(data, 'name') ?? existing?.name;
    final description =
        _readString(data, 'description') ?? existing?.description;
    final type = _readString(data, 'type') ?? existing?.type ?? 'percentage';
    final value = _readString(data, 'value') ?? existing?.value ?? '0';
    final status = _readString(data, 'status') ?? existing?.status;
    final expiredDate = _parseDate(data['expiredDate'] ?? data['expired_date']);
    final isDeleted = _readBool(data, 'isDeleted') ?? false;

    if (name == null && existing == null) {
      return;
    }

    final finalUuid = uuid ?? existingUuid;
    final companion = DiscountsCompanion(
      uuid: Value(finalUuid),
      serverId: serverId == null || serverId.isEmpty
          ? const Value.absent()
          : Value(serverId),
      name: Value(name ?? existing?.name ?? ''),
      description:
          description == null ? const Value.absent() : Value(description),
      type: Value(type),
      value: Value(value),
      status: status == null ? const Value.absent() : Value(status),
      expiredDate:
          expiredDate == null ? const Value.absent() : Value(expiredDate),
      syncStatus: const Value('synced'),
      updatedAt: Value(incomingUpdatedAt ?? TimezoneHelper.now()),
      isDeleted: Value(isDeleted),
    );

    await _database.into(_database.discounts).insertOnConflictUpdate(companion);
  }

  DateTime _readLastSync() {
    final stored = _settingsBox.get(_lastSyncKey);
    if (stored is String) {
      final parsed = DateTime.tryParse(stored);
      if (parsed != null) {
        return TimezoneHelper.toWib(parsed);
      }
      return TimezoneHelper.toWib(
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
    }
    return TimezoneHelper.toWib(
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  List<Map<String, dynamic>> _castList(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map<Map<String, dynamic>>(
            (item) => Map<String, dynamic>.from(item),
          )
          .toList();
    }
    return const [];
  }

  String? _lookupServerId(
    Map<String, dynamic> responseData,
    String key,
    String uuid,
  ) {
    final section = responseData[key];
    if (section is Map<String, dynamic>) {
      final entry = section[uuid];
      if (entry is Map<String, dynamic>) {
        return _readString(entry, 'serverId');
      }
      if (entry is String) {
        return entry;
      }
    }

    if (section is List) {
      final match = section
          .whereType<Map>()
          .map((dynamic item) => item.cast<String, dynamic>())
          .firstWhereOrNull(
            (item) => (_readString(item, 'uuid') ?? '') == uuid,
          );
      if (match != null) {
        return _readString(match, 'serverId');
      }
    }
    return null;
  }

  String? _readString(Map<String, dynamic> data, String key) {
    final camel = data[key];
    if (camel is String) return camel;
    final snake = data[_snakeCase(key)];
    if (snake is String) return snake;
    if (camel != null) return camel.toString();
    if (snake != null) return snake.toString();
    return null;
  }

  int? _readInt(Map<String, dynamic> data, String key) {
    final camel = data[key];
    final snake = data[_snakeCase(key)];
    return _coerceInt(camel) ?? _coerceInt(snake);
  }

  double? _readDouble(Map<String, dynamic> data, String key) {
    final camel = data[key];
    final snake = data[_snakeCase(key)];
    return _coerceDouble(camel) ?? _coerceDouble(snake);
  }

  bool? _readBool(Map<String, dynamic> data, String key) {
    final camel = data[key];
    final snake = data[_snakeCase(key)];
    return _coerceBool(camel) ?? _coerceBool(snake);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) {
      return TimezoneHelper.toWib(value);
    }
    if (value is int) {
      final parsed = DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
      return TimezoneHelper.toWib(parsed);
    }
    final string = value.toString();
    final parsed = DateTime.tryParse(string);
    if (parsed == null) return null;
    return TimezoneHelper.toWib(parsed);
  }

  int? _coerceInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _coerceDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  bool? _coerceBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  String _snakeCase(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (isUpper && i != 0) {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    }
    return buffer.toString();
  }
}

class SyncException implements Exception {
  SyncException(this.message);
  final String message;

  @override
  String toString() => 'SyncException: $message';
}
