import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:xpress/data/datasources/order_remote_datasource.dart';

part 'sync_order_bloc.freezed.dart';
part 'sync_order_event.dart';
part 'sync_order_state.dart';

class SyncOrderBloc extends Bloc<SyncOrderEvent, SyncOrderState> {
  final OrderRemoteDatasource orderRemoteDatasource;
  SyncOrderBloc(
    this.orderRemoteDatasource,
  ) : super(const _Initial()) {
    on<_SyncOrder>((event, emit) async {
      emit(const _Loading());
      final dataOrderNotSynced =
          await ProductLocalDatasource.instance.getOrderByIsNotSync();
      for (var order in dataOrderNotSynced) {
        final orderItem = await ProductLocalDatasource.instance
            .getOrderItemByOrderId(order.id!);

        final newOrder = order.copyWith(orderItems: orderItem);
        log("Order: ${newOrder.toMap()}");
        final result = await orderRemoteDatasource.saveOrder(newOrder);
        result.fold(
          // Left = Error
          (errorResponse) {
            final errorMessage = errorResponse.isLimitExceeded
                ? 'Sync Order Failed: ${errorResponse.message}'
                : 'Sync Order Failed: ${errorResponse.message}';
            emit(_Error(errorMessage));
            return;
          },
          // Right = Success
          (orderId) async {
            await ProductLocalDatasource.instance.updateOrderIsSync(order.id!);
          },
        );
      }
      emit(const _Loaded());
    });
  }
}
