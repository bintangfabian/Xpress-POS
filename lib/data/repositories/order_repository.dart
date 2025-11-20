import 'dart:math';

import 'package:drift/drift.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/presentation/home/models/order_model.dart';

import '../datasources/local/dao/order_dao.dart';
import '../datasources/local/database/database.dart';

class OrderRepository {
  OrderRepository({
    required AppDatabase database,
  }) : _orderDao = OrderDao(database);

  final OrderDao _orderDao;
  final Random _random = Random();

  /// Create order in local database (Drift)
  /// Returns order UUID
  Future<String> createOrderLocal(OrderModel orderModel) async {
    final uuid = _generateUuid();
    final now = TimezoneHelper.now();

    // Get store and user info
    final authData = await AuthLocalDataSource().getAuthData();
    final storeUuid = await AuthLocalDataSource().getStoreUuid() ?? '';
    final userId = authData.user?.id ?? 0;

    final orderCompanion = OrdersCompanion.insert(
      uuid: uuid,
      storeId: storeUuid,
      userId: userId,
      status: orderModel.status,
      subtotal: Value(orderModel.subTotal.toDouble()),
      discountAmount: Value(orderModel.discountAmount.toDouble()),
      serviceCharge: Value(orderModel.serviceCharge.toDouble()),
      total: Value(orderModel.total.toDouble()),
      paymentMethod: orderModel.paymentMethod.isEmpty
          ? const Value.absent()
          : Value(orderModel.paymentMethod),
      notes: orderModel.customerName.isEmpty
          ? const Value.absent()
          : Value(orderModel.customerName),
      syncStatus: const Value('pending'), // Will sync later
      updatedAt: Value(now),
      isDeleted: const Value(false),
    );

    await _orderDao.insertOrder(orderCompanion);

    // Convert order items
    final itemCompanions = orderModel.orderItems.map((item) {
      // Get product UUID from product_id or id
      final productId = item.product.productId ?? item.product.id;
      final productUuid = 'product-$productId';

      // Get price from product and convert to double
      final priceStr = item.product.price ?? '0';
      final price = priceStr.toIntegerFromText.toDouble();

      return OrderItemsCompanion.insert(
        orderUuid: uuid,
        productUuid: productUuid,
        quantity: item.quantity,
        price: price,
        cost: price, // Use price as cost if not available
        optionsJson: const Value.absent(),
        updatedAt: Value(now),
      );
    }).toList();

    await _orderDao.insertOrderItems(itemCompanions);
    return uuid;
  }

  Future<String> createOrderLocalFromDraft(LocalOrderDraft draft) async {
    final uuid = draft.uuid ?? _generateUuid();
    final now = TimezoneHelper.now();

    final orderCompanion = OrdersCompanion.insert(
      uuid: uuid,
      storeId: draft.storeId,
      userId: draft.userId,
      status: draft.status,
      subtotal: Value(draft.subtotal),
      discountAmount: Value(draft.discountAmount),
      serviceCharge: Value(draft.serviceCharge),
      total: Value(draft.total),
      paymentMethod: draft.paymentMethod == null
          ? const Value.absent()
          : Value(draft.paymentMethod!),
      notes: draft.notes == null ? const Value.absent() : Value(draft.notes!),
      syncStatus: const Value('pending'),
      updatedAt: Value(now),
      isDeleted: const Value(false),
    );

    await _orderDao.insertOrder(orderCompanion);

    final itemCompanions = draft.items.map((item) {
      return OrderItemsCompanion.insert(
        orderUuid: uuid,
        productUuid: item.productUuid,
        quantity: item.quantity,
        price: item.price,
        cost: item.cost,
        optionsJson: item.optionsJson == null
            ? const Value.absent()
            : Value(item.optionsJson!),
        updatedAt: Value(now),
      );
    }).toList();

    await _orderDao.insertOrderItems(itemCompanions);
    return uuid;
  }

  Future<List<Order>> getPendingOrders() {
    return _orderDao.getPendingOrders();
  }

  Future<List<Order>> getAllOrders() {
    return _orderDao.getAllOrders();
  }

  Future<List<Order>> getOrdersByDateRange(
      DateTime startDate, DateTime endDate) {
    return _orderDao.getOrdersByDateRange(startDate, endDate);
  }

  Future<List<OrderItem>> getOrderItems(String orderUuid) {
    return _orderDao.getItemsByOrder(orderUuid);
  }

  Future<void> updateSyncStatus(String uuid, String status) {
    return _orderDao.updateSyncStatus(uuid, status);
  }

  Future<void> markAsSynced(String uuid, {String? serverId}) {
    return _orderDao.markAsSynced(uuid, serverId: serverId);
  }

  String _generateUuid() {
    final timestamp = TimezoneHelper.now().microsecondsSinceEpoch;
    final randomPart = _random.nextInt(1 << 32);
    return 'order-$timestamp-$randomPart';
  }
}

class LocalOrderDraft {
  LocalOrderDraft({
    this.uuid,
    required this.storeId,
    required this.userId,
    required this.status,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.serviceCharge = 0,
    this.total = 0,
    this.paymentMethod,
    this.notes,
    this.items = const [],
  });

  final String? uuid;
  final String storeId;
  final int userId;
  final String status;
  final double subtotal;
  final double discountAmount;
  final double serviceCharge;
  final double total;
  final String? paymentMethod;
  final String? notes;
  final List<LocalOrderItemDraft> items;
}

class LocalOrderItemDraft {
  LocalOrderItemDraft({
    required this.productUuid,
    required this.quantity,
    required this.price,
    required this.cost,
    this.optionsJson,
  });

  final String productUuid;
  final int quantity;
  final double price;
  final double cost;
  final String? optionsJson;
}
