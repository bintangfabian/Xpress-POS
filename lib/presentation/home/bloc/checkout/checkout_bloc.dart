import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';
import 'package:xpress/presentation/table/models/draft_order_item.dart';
import 'package:xpress/presentation/table/models/draft_order_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/response/product_response_model.dart';
import '../../models/product_quantity.dart';
import '../../models/product_variant.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';
part 'checkout_bloc.freezed.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  List<ProductVariant>? _pendingVariants;
  void setPendingVariants(List<ProductVariant>? v) => _pendingVariants = v;

  CheckoutBloc() : super(const _Loaded([], null, 0, 0, 10, 5, 0, 0, '', null)) {
    on<_AddItem>((event, emit) {
      var currentState = state as _Loaded;
      List<ProductQuantity> items = [...currentState.items];
      var index = items.indexWhere((element) =>
          element.product.id == event.product.id &&
          _listEquals(element.variants, _pendingVariants));
      emit(_Loading());
      if (index != -1) {
        items[index] = ProductQuantity(
            product: event.product,
            quantity: items[index].quantity + 1,
            variants: items[index].variants);
      } else {
        items.add(ProductQuantity(
            product: event.product, quantity: 1, variants: _pendingVariants));
      }
      _pendingVariants = null;
      emit(_Loaded(
        items,
        currentState.discountModel,
        currentState.discount,
        currentState.discountAmount,
        currentState.tax,
        currentState.serviceCharge,
        currentState.totalQuantity,
        currentState.totalPrice,
        currentState.draftName,
        currentState.orderType, // ✅ tambah
      ));
    });

    on<_RemoveItem>((event, emit) {
      var currentState = state as _Loaded;
      List<ProductQuantity> items = [...currentState.items];
      var index = items.indexWhere((element) =>
          element.product.id == event.product.id &&
          _listEquals(element.variants, _pendingVariants));
      emit(_Loading());
      if (index != -1) {
        if (items[index].quantity > 1) {
          items[index] = ProductQuantity(
              product: event.product,
              quantity: items[index].quantity - 1,
              variants: items[index].variants);
        } else {
          items.removeAt(index);
        }
      }
      _pendingVariants = null;
      emit(_Loaded(
        items,
        currentState.discountModel,
        currentState.discount,
        currentState.discountAmount,
        currentState.tax,
        currentState.serviceCharge,
        currentState.totalQuantity,
        currentState.totalPrice,
        currentState.draftName,
        currentState.orderType, // ✅ tambah
      ));
    });

    on<_Started>((event, emit) {
      emit(const _Loaded([], null, 0, 0, 0, 0, 0, 0, '', null));
    });

    on<_AddDiscount>((event, emit) {
      var currentState = state as _Loaded;

      // Calculate subtotal
      final subtotal = currentState.items
          .map((e) => (e.product.price?.toIntegerFromText ?? 0) * e.quantity)
          .fold(0, (a, b) => a + b);

      // Calculate discount amount
      int discountAmount = 0;
      if (event.discount != null) {
        final val = double.tryParse(event.discount.value ?? '0') ?? 0.0;
        final type = (event.discount.type ?? '').toLowerCase();

        if (type == 'percentage') {
          discountAmount = (subtotal * (val / 100)).floor();
        } else if (type == 'fixed') {
          discountAmount = val.toInt();
        }
        discountAmount = discountAmount.clamp(0, subtotal);
      }

      emit(_Loaded(
        currentState.items,
        event.discount,
        currentState.discount,
        discountAmount,
        currentState.tax,
        currentState.serviceCharge,
        currentState.totalQuantity,
        currentState.totalPrice,
        currentState.draftName,
        currentState.orderType,
      ));
    });

    on<_RemoveDiscount>((event, emit) {
      var currentState = state as _Loaded;
      emit(_Loaded(
        currentState.items,
        null,
        currentState.discount,
        currentState.discountAmount,
        currentState.tax,
        currentState.serviceCharge,
        currentState.totalQuantity,
        currentState.totalPrice,
        currentState.draftName,
        currentState.orderType, // ✅ tambah
      ));
    });

    on<_AddTax>((event, emit) {
      var currentState = state as _Loaded;
      emit(_Loaded(
        currentState.items,
        currentState.discountModel,
        currentState.discount,
        currentState.discountAmount,
        event.tax,
        currentState.serviceCharge,
        currentState.totalQuantity,
        currentState.totalPrice,
        currentState.draftName,
        currentState.orderType, // ✅ tambah
      ));
    });

    on<_AddServiceCharge>((event, emit) {
      var currentState = state as _Loaded;
      emit(_Loaded(
        currentState.items,
        currentState.discountModel,
        currentState.discount,
        currentState.discountAmount,
        currentState.tax,
        event.serviceCharge,
        currentState.totalQuantity,
        currentState.totalPrice,
        currentState.draftName,
        currentState.orderType, // ✅ tambah
      ));
    });

    on<_RemoveTax>((event, emit) {
      var currentState = state as _Loaded;
      emit(_Loaded(
        currentState.items,
        currentState.discountModel,
        currentState.discount,
        currentState.discountAmount,
        0,
        currentState.serviceCharge,
        currentState.totalQuantity,
        currentState.totalPrice,
        currentState.draftName,
        currentState.orderType, // ✅ tambah
      ));
    });

    on<_RemoveServiceCharge>((event, emit) {
      var currentState = state as _Loaded;
      emit(_Loaded(
        currentState.items,
        currentState.discountModel,
        currentState.discount,
        currentState.discountAmount,
        currentState.tax,
        0,
        currentState.totalQuantity,
        currentState.totalPrice,
        currentState.draftName,
        currentState.orderType, // ✅ tambah
      ));
    });

    on<_SaveDraftOrder>((event, emit) async {
      var currentStates = state as _Loaded;
      emit(const _Loading());

      final draftOrder = DraftOrderModel(
        orders: currentStates.items
            .map((e) => DraftOrderItem(
                  product: e.product,
                  quantity: e.quantity,
                ))
            .toList(),
        totalQuantity: currentStates.totalQuantity,
        totalPrice: currentStates.totalPrice,
        discount: currentStates.discount,
        discountAmount: event.discountAmount,
        tax: currentStates.tax,
        serviceCharge: currentStates.serviceCharge,
        subTotal: currentStates.totalPrice,
        tableNumber: event.tableNumber,
        draftName: event.draftName,
        transactionTime:
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );
      log("draftOrder12: ${draftOrder.toMapForLocal()}");
      final orderDraftId =
          await ProductLocalDatasource.instance.saveDraftOrder(draftOrder);
      emit(_SavedDraftOrder(orderDraftId));
    });

    // load draft order
    on<_LoadDraftOrder>((event, emit) async {
      emit(const _Loading());
      final draftOrder = event.data;
      log("draftOrder: ${draftOrder.toMap()}");
      emit(_Loaded(
        draftOrder.orders
            .map((e) =>
                ProductQuantity(product: e.product, quantity: e.quantity))
            .toList(),
        null,
        draftOrder.discount,
        draftOrder.discountAmount,
        draftOrder.tax,
        draftOrder.serviceCharge,
        draftOrder.totalQuantity,
        draftOrder.totalPrice,
        draftOrder.draftName,
        null, // ✅ belum ada orderType saat load draft
      ));
    });

    // ✅ Clear Order Handler
    on<_ClearOrder>(
      (event, emit) {
        final current = state;
        if (current is _Loaded) {
          emit(const _Loading());
          emit(
            _Loaded(
              [],
              null,
              0,
              0,
              current.tax,
              current.serviceCharge,
              0,
              0,
              '',
              null, // ✅ reset orderType juga
            ),
          );
        }
      },
    );

    // ✅ Set OrderType Handler
    on<_SetOrderType>((event, emit) {
      state.maybeWhen(
        loaded: (items, discountModel, discount, discountAmount, tax,
            serviceCharge, totalQuantity, totalPrice, draftName, orderType) {
          emit(CheckoutState.loaded(
            items,
            discountModel,
            discount,
            discountAmount,
            tax,
            serviceCharge,
            totalQuantity,
            totalPrice,
            draftName,
            event.orderType, // ✅ update orderType
          ));
        },
        orElse: () {},
      );
    });
  }

  bool _listEquals(List<ProductVariant>? a, List<ProductVariant>? b) {
    if (identical(a, b)) return true;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
