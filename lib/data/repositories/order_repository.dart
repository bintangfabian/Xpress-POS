import 'dart:math';

import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../datasources/local/dao/order_dao.dart';
import '../datasources/local/database/database.dart';

class OrderRepository {
  OrderRepository({
    required AppDatabase database,
  }) : _orderDao = OrderDao(database);

  final OrderDao _orderDao;
  final Random _random = Random();

  Future<String> createOrderLocal(LocalOrderDraft draft) async {
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

  Future<List<OrderItem>> getOrderItems(String orderUuid) {
    return _orderDao.getItemsByOrder(orderUuid);
  }

  Future<void> updateSyncStatus(String uuid, String status) {
    return _orderDao.updateSyncStatus(uuid, status);
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
