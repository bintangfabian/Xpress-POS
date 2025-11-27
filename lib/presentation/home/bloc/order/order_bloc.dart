import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/local/database/database.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/repositories/order_repository.dart';
import 'package:xpress/data/repositories/sync_repository.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

import '../../models/order_model.dart';
import '../../models/product_quantity.dart';

part 'order_bloc.freezed.dart';
part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRemoteDatasource orderRemoteDatasource;
  final OrderRepository _orderRepository;
  final OnlineCheckerBloc _onlineCheckerBloc;
  final SyncRepository? syncRepository;

  OrderBloc(
    this.orderRemoteDatasource, {
    OrderRepository? orderRepository,
    OnlineCheckerBloc? onlineCheckerBloc,
    this.syncRepository,
  })  : _orderRepository =
            orderRepository ?? OrderRepository(database: AppDatabase.instance),
        _onlineCheckerBloc = onlineCheckerBloc ?? OnlineCheckerBloc(),
        super(const _Initial()) {
    on<_Order>((event, emit) async {
      emit(const _Loading());

      final subTotal = event.items.fold<int>(
          0,
          (previousValue, element) =>
              previousValue +
              (element.product.price!.toIntegerFromText * element.quantity));

      final totalItem = event.items.fold<int>(
          0, (previousValue, element) => previousValue + element.quantity);

      final userData = await AuthLocalDataSource().getAuthData();

      final dataInput = OrderModel(
        subTotal: subTotal,
        paymentAmount: event.paymentAmount,
        tax: event.tax,
        discount: event.discount,
        discountAmount: event.discountAmount,
        serviceCharge: event.serviceCharge,
        total: event.totalPriceFinal,
        paymentMethod: event.paymentMethod,
        totalItem: totalItem,
        idKasir: userData.user?.id ?? 1,
        namaKasir: userData.user?.name ?? 'Kasir A',
        transactionTime: TimezoneHelper.now().toIso8601String(),
        customerName: event.customerName,
        tableNumber: event.tableNumber,
        status: event.status,
        paymentStatus: event.paymentStatus,
        isSync: 0,
        operationMode: normalizeOperationMode(event.orderType),
        orderItems: event.items,
      );

      // ✅ ALWAYS save to local database first (Drift)
      final orderUuid = await _orderRepository.createOrderLocal(dataInput);

      // ✅ Also save to SQFlite for backward compatibility (temporary)
      int sqfliteId = 0;
      try {
        sqfliteId = await ProductLocalDatasource.instance.saveOrder(dataInput);
      } catch (e) {
        log('Warning: Failed to save to SQFlite: $e');
      }

      final newData = dataInput.copyWith(id: sqfliteId);
      final orderItem = sqfliteId > 0
          ? await ProductLocalDatasource.instance
              .getOrderItemByOrderId(sqfliteId)
          : <ProductQuantity>[];

      final newOrder = newData.copyWith(orderItems: orderItem);

      // ✅ Try to sync if online, otherwise queue for later
      if (_onlineCheckerBloc.isOnline) {
        try {
          final result = await orderRemoteDatasource.saveOrder(newOrder);
          result.fold(
            // Left = Error
            (errorResponse) {
              log('Order creation failed: ${errorResponse.message}');
              // Order remains in local database with pending status
              // Error will be handled in UI layer when user tries to sync
            },
            // Right = Success
            (orderId) async {
              // Mark as synced in both databases
              await _orderRepository.markAsSynced(orderUuid);
              if (sqfliteId > 0) {
                await ProductLocalDatasource.instance
                    .updateOrderIsSync(sqfliteId);
              }
            },
          );
        } catch (e) {
          log('Failed to sync order immediately: $e');
          // Order remains in local database with pending status
        }
      } else {
        log('Offline: Order saved locally, will sync when online');
      }

      emit(_Loaded(
        newData,
        sqfliteId,
      ));
    });
  }
}
