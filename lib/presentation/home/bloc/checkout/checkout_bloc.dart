import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:xpress/core/extensions/string_ext.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';
import 'package:xpress/presentation/table/models/draft_order_item.dart';
import 'package:xpress/presentation/table/models/draft_order_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:xpress/core/utils/timezone_helper.dart';

import '../../../../data/models/response/product_response_model.dart';
import '../../models/product_quantity.dart';
import '../../models/product_variant.dart';
import '../../models/product_modifier.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';
part 'checkout_bloc.freezed.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  List<ProductVariant>? _pendingVariants;
  List<ProductModifier>? _pendingModifiers;
  void setPendingVariants(List<ProductVariant>? v) => _pendingVariants = v;
  void setPendingModifiers(List<ProductModifier>? m) => _pendingModifiers = m;

  CheckoutBloc() : super(const _Loaded([], null, 0, 0, 10, 5, 0, 0, '', null)) {
    on<_AddItem>((event, emit) {
      var currentState = state as _Loaded;
      List<ProductQuantity> items = [...currentState.items];
      var index = items.indexWhere((element) =>
          element.product.id == event.product.id &&
          _listEquals(element.variants, _pendingVariants) &&
          _listEqualsModifiers(element.modifiers, _pendingModifiers));
      emit(_Loading());
      if (index != -1) {
        items[index] = ProductQuantity(
            product: event.product,
            quantity: items[index].quantity + 1,
            variants: items[index].variants,
            modifiers: items[index].modifiers);
      } else {
        items.add(ProductQuantity(
            product: event.product,
            quantity: 1,
            variants: _pendingVariants,
            modifiers: _pendingModifiers));
      }
      _pendingVariants = null;
      _pendingModifiers = null;
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
          _listEquals(element.variants, _pendingVariants) &&
          _listEqualsModifiers(element.modifiers, _pendingModifiers));
      emit(_Loading());
      if (index != -1) {
        if (items[index].quantity > 1) {
          items[index] = ProductQuantity(
              product: event.product,
              quantity: items[index].quantity - 1,
              variants: items[index].variants,
              modifiers: items[index].modifiers);
        } else {
          items.removeAt(index);
        }
      }
      _pendingVariants = null;
      _pendingModifiers = null;
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
      final discount = event.discount;
      final discountValue = double.tryParse(discount.value ?? '0') ?? 0.0;
      final discountType = (discount.type ?? '').toLowerCase();

      if (discountType == 'percentage') {
        discountAmount = (subtotal * (discountValue / 100)).floor();
      } else if (discountType == 'fixed') {
        discountAmount = discountValue.toInt();
      }
      discountAmount = discountAmount.clamp(0, subtotal);

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
            DateFormat('yyyy-MM-dd HH:mm:ss').format(TimezoneHelper.now()),
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

    // ✅ Update Item Variants Handler
    on<_UpdateItemVariants>((event, emit) {
      var currentState = state as _Loaded;
      List<ProductQuantity> items = [...currentState.items];

      log('========================================');
      log('UPDATE ITEM VARIANTS');
      log('Product: ${event.product.name} (ID: ${event.product.id})');
      log('Old variants: ${event.oldVariants?.map((v) => v.name).join(", ") ?? "none"}');
      log('New variants: ${event.newVariants.map((v) => v.name).join(", ")}');
      log('Current cart items: ${items.length}');

      // Find the item with matching product and old variants
      var index = -1;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        log('  Checking item $i: ${item.product.name} (ID: ${item.product.id})');
        log('    Variants: ${item.variants?.map((v) => v.name).join(", ") ?? "none"}');

        if (item.product.id == event.product.id &&
            _listEquals(item.variants, event.oldVariants)) {
          index = i;
          log('  ✅ MATCH FOUND at index $i');
          break;
        }
      }

      if (index == -1) {
        log('⚠️ NO MATCH - Trying fallback match by product ID only');
        // Fallback: Find by product ID only (first occurrence)
        index = items
            .indexWhere((element) => element.product.id == event.product.id);

        if (index != -1) {
          log('  ✅ Fallback match found at index $index');
        }
      }

      emit(_Loading());

      if (index != -1) {
        // Update the item with new variants, keep the quantity
        final oldQuantity = items[index].quantity;
        items[index] = ProductQuantity(
          product: event.product,
          quantity: oldQuantity,
          variants: event.newVariants,
        );

        log('✅ UPDATED item at index $index');
        log('   Quantity preserved: $oldQuantity');
        log('   New variants: ${event.newVariants.map((v) => v.name).join(", ")}');
      } else {
        log('❌ Item not found for variant update - no action taken');
      }

      log('========================================');

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
        currentState.orderType,
      ));
    });

    // ✅ Update Item Variants and Modifiers Handler
    on<_UpdateItemVariantsAndModifiers>((event, emit) {
      var currentState = state as _Loaded;
      List<ProductQuantity> items = [...currentState.items];

      log('========================================');
      log('UPDATE ITEM VARIANTS AND MODIFIERS');
      log('Product: ${event.product.name} (ID: ${event.product.id})');
      log('Old variants: ${event.oldVariants?.map((v) => v.name).join(", ") ?? "none"}');
      log('New variants: ${event.newVariants.map((v) => v.name).join(", ")}');
      log('Old modifiers: ${event.oldModifiers?.map((m) => m.name).join(", ") ?? "none"}');
      log('New modifiers: ${event.newModifiers.map((m) => m.name).join(", ")}');
      log('Current cart items: ${items.length}');

      // Find the item with matching product, old variants, and old modifiers
      var index = -1;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        log('  Checking item $i: ${item.product.name} (ID: ${item.product.id})');
        log('    Variants: ${item.variants?.map((v) => v.name).join(", ") ?? "none"}');
        log('    Modifiers: ${item.modifiers?.map((m) => m.name).join(", ") ?? "none"}');

        if (item.product.id == event.product.id &&
            _listEquals(item.variants, event.oldVariants) &&
            _listEqualsModifiers(item.modifiers, event.oldModifiers)) {
          index = i;
          log('  ✅ MATCH FOUND at index $i');
          break;
        }
      }

      if (index == -1) {
        log('⚠️ NO MATCH - Trying fallback match by product ID only');
        // Fallback: Find by product ID only (first occurrence)
        index = items
            .indexWhere((element) => element.product.id == event.product.id);

        if (index != -1) {
          log('  ✅ Fallback match found at index $index');
        }
      }

      emit(_Loading());

      if (index != -1) {
        // Update the item with new variants and modifiers, keep the quantity
        final oldQuantity = items[index].quantity;
        items[index] = ProductQuantity(
          product: event.product,
          quantity: oldQuantity,
          variants: event.newVariants.isEmpty ? null : event.newVariants,
          modifiers: event.newModifiers.isEmpty ? null : event.newModifiers,
        );

        log('✅ UPDATED item at index $index');
        log('   Quantity preserved: $oldQuantity');
        log('   New variants: ${event.newVariants.map((v) => v.name).join(", ")}');
        log('   New modifiers: ${event.newModifiers.map((m) => m.name).join(", ")}');
      } else {
        log('❌ Item not found for update - no action taken');
      }

      log('========================================');

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
        currentState.orderType,
      ));
    });
  }

  bool _listEquals(List<ProductVariant>? a, List<ProductVariant>? b) {
    if (identical(a, b)) return true;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    // Compare by ID instead of object equality
    for (int i = 0; i < a.length; i++) {
      // If both have IDs, compare by ID
      if (a[i].id != null && b[i].id != null) {
        if (a[i].id != b[i].id) return false;
      } else {
        // Fallback to name and price comparison
        if (a[i].name != b[i].name ||
            a[i].priceAdjustment != b[i].priceAdjustment) {
          return false;
        }
      }
    }
    return true;
  }

  bool _listEqualsModifiers(
      List<ProductModifier>? a, List<ProductModifier>? b) {
    if (identical(a, b)) return true;
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;

    // Compare by ID instead of object equality
    for (int i = 0; i < a.length; i++) {
      // If both have IDs, compare by ID
      if (a[i].id != null && b[i].id != null) {
        if (a[i].id != b[i].id) return false;
      } else {
        // Fallback to name comparison if IDs are missing
        if (a[i].name != b[i].name) return false;
      }
    }
    return true;
  }
}
