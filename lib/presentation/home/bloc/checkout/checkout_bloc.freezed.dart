// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CheckoutEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutEventCopyWith<$Res> {
  factory $CheckoutEventCopyWith(
          CheckoutEvent value, $Res Function(CheckoutEvent) then) =
      _$CheckoutEventCopyWithImpl<$Res, CheckoutEvent>;
}

/// @nodoc
class _$CheckoutEventCopyWithImpl<$Res, $Val extends CheckoutEvent>
    implements $CheckoutEventCopyWith<$Res> {
  _$CheckoutEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$StartedImplCopyWith<$Res> {
  factory _$$StartedImplCopyWith(
          _$StartedImpl value, $Res Function(_$StartedImpl) then) =
      __$$StartedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$StartedImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$StartedImpl>
    implements _$$StartedImplCopyWith<$Res> {
  __$$StartedImplCopyWithImpl(
      _$StartedImpl _value, $Res Function(_$StartedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$StartedImpl implements _Started {
  const _$StartedImpl();

  @override
  String toString() {
    return 'CheckoutEvent.started()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$StartedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return started();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return started?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class _Started implements CheckoutEvent {
  const factory _Started() = _$StartedImpl;
}

/// @nodoc
abstract class _$$AddItemImplCopyWith<$Res> {
  factory _$$AddItemImplCopyWith(
          _$AddItemImpl value, $Res Function(_$AddItemImpl) then) =
      __$$AddItemImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Product product});
}

/// @nodoc
class __$$AddItemImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$AddItemImpl>
    implements _$$AddItemImplCopyWith<$Res> {
  __$$AddItemImplCopyWithImpl(
      _$AddItemImpl _value, $Res Function(_$AddItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? product = null,
  }) {
    return _then(_$AddItemImpl(
      null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as Product,
    ));
  }
}

/// @nodoc

class _$AddItemImpl implements _AddItem {
  const _$AddItemImpl(this.product);

  @override
  final Product product;

  @override
  String toString() {
    return 'CheckoutEvent.addItem(product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddItemImpl &&
            (identical(other.product, product) || other.product == product));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddItemImplCopyWith<_$AddItemImpl> get copyWith =>
      __$$AddItemImplCopyWithImpl<_$AddItemImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return addItem(product);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return addItem?.call(product);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (addItem != null) {
      return addItem(product);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return addItem(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return addItem?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (addItem != null) {
      return addItem(this);
    }
    return orElse();
  }
}

abstract class _AddItem implements CheckoutEvent {
  const factory _AddItem(final Product product) = _$AddItemImpl;

  Product get product;
  @JsonKey(ignore: true)
  _$$AddItemImplCopyWith<_$AddItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RemoveItemImplCopyWith<$Res> {
  factory _$$RemoveItemImplCopyWith(
          _$RemoveItemImpl value, $Res Function(_$RemoveItemImpl) then) =
      __$$RemoveItemImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Product product});
}

/// @nodoc
class __$$RemoveItemImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$RemoveItemImpl>
    implements _$$RemoveItemImplCopyWith<$Res> {
  __$$RemoveItemImplCopyWithImpl(
      _$RemoveItemImpl _value, $Res Function(_$RemoveItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? product = null,
  }) {
    return _then(_$RemoveItemImpl(
      null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as Product,
    ));
  }
}

/// @nodoc

class _$RemoveItemImpl implements _RemoveItem {
  const _$RemoveItemImpl(this.product);

  @override
  final Product product;

  @override
  String toString() {
    return 'CheckoutEvent.removeItem(product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoveItemImpl &&
            (identical(other.product, product) || other.product == product));
  }

  @override
  int get hashCode => Object.hash(runtimeType, product);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RemoveItemImplCopyWith<_$RemoveItemImpl> get copyWith =>
      __$$RemoveItemImplCopyWithImpl<_$RemoveItemImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return removeItem(product);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return removeItem?.call(product);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (removeItem != null) {
      return removeItem(product);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return removeItem(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return removeItem?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (removeItem != null) {
      return removeItem(this);
    }
    return orElse();
  }
}

abstract class _RemoveItem implements CheckoutEvent {
  const factory _RemoveItem(final Product product) = _$RemoveItemImpl;

  Product get product;
  @JsonKey(ignore: true)
  _$$RemoveItemImplCopyWith<_$RemoveItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AddDiscountImplCopyWith<$Res> {
  factory _$$AddDiscountImplCopyWith(
          _$AddDiscountImpl value, $Res Function(_$AddDiscountImpl) then) =
      __$$AddDiscountImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Discount discount});
}

/// @nodoc
class __$$AddDiscountImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$AddDiscountImpl>
    implements _$$AddDiscountImplCopyWith<$Res> {
  __$$AddDiscountImplCopyWithImpl(
      _$AddDiscountImpl _value, $Res Function(_$AddDiscountImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? discount = null,
  }) {
    return _then(_$AddDiscountImpl(
      null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as Discount,
    ));
  }
}

/// @nodoc

class _$AddDiscountImpl implements _AddDiscount {
  const _$AddDiscountImpl(this.discount);

  @override
  final Discount discount;

  @override
  String toString() {
    return 'CheckoutEvent.addDiscount(discount: $discount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddDiscountImpl &&
            (identical(other.discount, discount) ||
                other.discount == discount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, discount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddDiscountImplCopyWith<_$AddDiscountImpl> get copyWith =>
      __$$AddDiscountImplCopyWithImpl<_$AddDiscountImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return addDiscount(discount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return addDiscount?.call(discount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (addDiscount != null) {
      return addDiscount(discount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return addDiscount(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return addDiscount?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (addDiscount != null) {
      return addDiscount(this);
    }
    return orElse();
  }
}

abstract class _AddDiscount implements CheckoutEvent {
  const factory _AddDiscount(final Discount discount) = _$AddDiscountImpl;

  Discount get discount;
  @JsonKey(ignore: true)
  _$$AddDiscountImplCopyWith<_$AddDiscountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RemoveDiscountImplCopyWith<$Res> {
  factory _$$RemoveDiscountImplCopyWith(_$RemoveDiscountImpl value,
          $Res Function(_$RemoveDiscountImpl) then) =
      __$$RemoveDiscountImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RemoveDiscountImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$RemoveDiscountImpl>
    implements _$$RemoveDiscountImplCopyWith<$Res> {
  __$$RemoveDiscountImplCopyWithImpl(
      _$RemoveDiscountImpl _value, $Res Function(_$RemoveDiscountImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RemoveDiscountImpl implements _RemoveDiscount {
  const _$RemoveDiscountImpl();

  @override
  String toString() {
    return 'CheckoutEvent.removeDiscount()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RemoveDiscountImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return removeDiscount();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return removeDiscount?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (removeDiscount != null) {
      return removeDiscount();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return removeDiscount(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return removeDiscount?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (removeDiscount != null) {
      return removeDiscount(this);
    }
    return orElse();
  }
}

abstract class _RemoveDiscount implements CheckoutEvent {
  const factory _RemoveDiscount() = _$RemoveDiscountImpl;
}

/// @nodoc
abstract class _$$AddTaxImplCopyWith<$Res> {
  factory _$$AddTaxImplCopyWith(
          _$AddTaxImpl value, $Res Function(_$AddTaxImpl) then) =
      __$$AddTaxImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int tax});
}

/// @nodoc
class __$$AddTaxImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$AddTaxImpl>
    implements _$$AddTaxImplCopyWith<$Res> {
  __$$AddTaxImplCopyWithImpl(
      _$AddTaxImpl _value, $Res Function(_$AddTaxImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tax = null,
  }) {
    return _then(_$AddTaxImpl(
      null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AddTaxImpl implements _AddTax {
  const _$AddTaxImpl(this.tax);

  @override
  final int tax;

  @override
  String toString() {
    return 'CheckoutEvent.addTax(tax: $tax)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddTaxImpl &&
            (identical(other.tax, tax) || other.tax == tax));
  }

  @override
  int get hashCode => Object.hash(runtimeType, tax);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddTaxImplCopyWith<_$AddTaxImpl> get copyWith =>
      __$$AddTaxImplCopyWithImpl<_$AddTaxImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return addTax(tax);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return addTax?.call(tax);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (addTax != null) {
      return addTax(tax);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return addTax(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return addTax?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (addTax != null) {
      return addTax(this);
    }
    return orElse();
  }
}

abstract class _AddTax implements CheckoutEvent {
  const factory _AddTax(final int tax) = _$AddTaxImpl;

  int get tax;
  @JsonKey(ignore: true)
  _$$AddTaxImplCopyWith<_$AddTaxImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AddServiceChargeImplCopyWith<$Res> {
  factory _$$AddServiceChargeImplCopyWith(_$AddServiceChargeImpl value,
          $Res Function(_$AddServiceChargeImpl) then) =
      __$$AddServiceChargeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int serviceCharge});
}

/// @nodoc
class __$$AddServiceChargeImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$AddServiceChargeImpl>
    implements _$$AddServiceChargeImplCopyWith<$Res> {
  __$$AddServiceChargeImplCopyWithImpl(_$AddServiceChargeImpl _value,
      $Res Function(_$AddServiceChargeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serviceCharge = null,
  }) {
    return _then(_$AddServiceChargeImpl(
      null == serviceCharge
          ? _value.serviceCharge
          : serviceCharge // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AddServiceChargeImpl implements _AddServiceCharge {
  const _$AddServiceChargeImpl(this.serviceCharge);

  @override
  final int serviceCharge;

  @override
  String toString() {
    return 'CheckoutEvent.addServiceCharge(serviceCharge: $serviceCharge)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddServiceChargeImpl &&
            (identical(other.serviceCharge, serviceCharge) ||
                other.serviceCharge == serviceCharge));
  }

  @override
  int get hashCode => Object.hash(runtimeType, serviceCharge);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddServiceChargeImplCopyWith<_$AddServiceChargeImpl> get copyWith =>
      __$$AddServiceChargeImplCopyWithImpl<_$AddServiceChargeImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return addServiceCharge(serviceCharge);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return addServiceCharge?.call(serviceCharge);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (addServiceCharge != null) {
      return addServiceCharge(serviceCharge);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return addServiceCharge(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return addServiceCharge?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (addServiceCharge != null) {
      return addServiceCharge(this);
    }
    return orElse();
  }
}

abstract class _AddServiceCharge implements CheckoutEvent {
  const factory _AddServiceCharge(final int serviceCharge) =
      _$AddServiceChargeImpl;

  int get serviceCharge;
  @JsonKey(ignore: true)
  _$$AddServiceChargeImplCopyWith<_$AddServiceChargeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RemoveTaxImplCopyWith<$Res> {
  factory _$$RemoveTaxImplCopyWith(
          _$RemoveTaxImpl value, $Res Function(_$RemoveTaxImpl) then) =
      __$$RemoveTaxImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RemoveTaxImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$RemoveTaxImpl>
    implements _$$RemoveTaxImplCopyWith<$Res> {
  __$$RemoveTaxImplCopyWithImpl(
      _$RemoveTaxImpl _value, $Res Function(_$RemoveTaxImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RemoveTaxImpl implements _RemoveTax {
  const _$RemoveTaxImpl();

  @override
  String toString() {
    return 'CheckoutEvent.removeTax()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RemoveTaxImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return removeTax();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return removeTax?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (removeTax != null) {
      return removeTax();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return removeTax(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return removeTax?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (removeTax != null) {
      return removeTax(this);
    }
    return orElse();
  }
}

abstract class _RemoveTax implements CheckoutEvent {
  const factory _RemoveTax() = _$RemoveTaxImpl;
}

/// @nodoc
abstract class _$$RemoveServiceChargeImplCopyWith<$Res> {
  factory _$$RemoveServiceChargeImplCopyWith(_$RemoveServiceChargeImpl value,
          $Res Function(_$RemoveServiceChargeImpl) then) =
      __$$RemoveServiceChargeImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RemoveServiceChargeImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$RemoveServiceChargeImpl>
    implements _$$RemoveServiceChargeImplCopyWith<$Res> {
  __$$RemoveServiceChargeImplCopyWithImpl(_$RemoveServiceChargeImpl _value,
      $Res Function(_$RemoveServiceChargeImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RemoveServiceChargeImpl implements _RemoveServiceCharge {
  const _$RemoveServiceChargeImpl();

  @override
  String toString() {
    return 'CheckoutEvent.removeServiceCharge()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RemoveServiceChargeImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return removeServiceCharge();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return removeServiceCharge?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (removeServiceCharge != null) {
      return removeServiceCharge();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return removeServiceCharge(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return removeServiceCharge?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (removeServiceCharge != null) {
      return removeServiceCharge(this);
    }
    return orElse();
  }
}

abstract class _RemoveServiceCharge implements CheckoutEvent {
  const factory _RemoveServiceCharge() = _$RemoveServiceChargeImpl;
}

/// @nodoc
abstract class _$$SaveDraftOrderImplCopyWith<$Res> {
  factory _$$SaveDraftOrderImplCopyWith(_$SaveDraftOrderImpl value,
          $Res Function(_$SaveDraftOrderImpl) then) =
      __$$SaveDraftOrderImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int tableNumber, String draftName, int discountAmount});
}

/// @nodoc
class __$$SaveDraftOrderImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$SaveDraftOrderImpl>
    implements _$$SaveDraftOrderImplCopyWith<$Res> {
  __$$SaveDraftOrderImplCopyWithImpl(
      _$SaveDraftOrderImpl _value, $Res Function(_$SaveDraftOrderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tableNumber = null,
    Object? draftName = null,
    Object? discountAmount = null,
  }) {
    return _then(_$SaveDraftOrderImpl(
      null == tableNumber
          ? _value.tableNumber
          : tableNumber // ignore: cast_nullable_to_non_nullable
              as int,
      null == draftName
          ? _value.draftName
          : draftName // ignore: cast_nullable_to_non_nullable
              as String,
      null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SaveDraftOrderImpl implements _SaveDraftOrder {
  const _$SaveDraftOrderImpl(
      this.tableNumber, this.draftName, this.discountAmount);

  @override
  final int tableNumber;
  @override
  final String draftName;
  @override
  final int discountAmount;

  @override
  String toString() {
    return 'CheckoutEvent.saveDraftOrder(tableNumber: $tableNumber, draftName: $draftName, discountAmount: $discountAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SaveDraftOrderImpl &&
            (identical(other.tableNumber, tableNumber) ||
                other.tableNumber == tableNumber) &&
            (identical(other.draftName, draftName) ||
                other.draftName == draftName) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, tableNumber, draftName, discountAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SaveDraftOrderImplCopyWith<_$SaveDraftOrderImpl> get copyWith =>
      __$$SaveDraftOrderImplCopyWithImpl<_$SaveDraftOrderImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return saveDraftOrder(tableNumber, draftName, discountAmount);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return saveDraftOrder?.call(tableNumber, draftName, discountAmount);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (saveDraftOrder != null) {
      return saveDraftOrder(tableNumber, draftName, discountAmount);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return saveDraftOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return saveDraftOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (saveDraftOrder != null) {
      return saveDraftOrder(this);
    }
    return orElse();
  }
}

abstract class _SaveDraftOrder implements CheckoutEvent {
  const factory _SaveDraftOrder(final int tableNumber, final String draftName,
      final int discountAmount) = _$SaveDraftOrderImpl;

  int get tableNumber;
  String get draftName;
  int get discountAmount;
  @JsonKey(ignore: true)
  _$$SaveDraftOrderImplCopyWith<_$SaveDraftOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadDraftOrderImplCopyWith<$Res> {
  factory _$$LoadDraftOrderImplCopyWith(_$LoadDraftOrderImpl value,
          $Res Function(_$LoadDraftOrderImpl) then) =
      __$$LoadDraftOrderImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DraftOrderModel data});
}

/// @nodoc
class __$$LoadDraftOrderImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$LoadDraftOrderImpl>
    implements _$$LoadDraftOrderImplCopyWith<$Res> {
  __$$LoadDraftOrderImplCopyWithImpl(
      _$LoadDraftOrderImpl _value, $Res Function(_$LoadDraftOrderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
  }) {
    return _then(_$LoadDraftOrderImpl(
      null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as DraftOrderModel,
    ));
  }
}

/// @nodoc

class _$LoadDraftOrderImpl implements _LoadDraftOrder {
  const _$LoadDraftOrderImpl(this.data);

  @override
  final DraftOrderModel data;

  @override
  String toString() {
    return 'CheckoutEvent.loadDraftOrder(data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadDraftOrderImpl &&
            (identical(other.data, data) || other.data == data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadDraftOrderImplCopyWith<_$LoadDraftOrderImpl> get copyWith =>
      __$$LoadDraftOrderImplCopyWithImpl<_$LoadDraftOrderImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return loadDraftOrder(data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return loadDraftOrder?.call(data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (loadDraftOrder != null) {
      return loadDraftOrder(data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return loadDraftOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return loadDraftOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (loadDraftOrder != null) {
      return loadDraftOrder(this);
    }
    return orElse();
  }
}

abstract class _LoadDraftOrder implements CheckoutEvent {
  const factory _LoadDraftOrder(final DraftOrderModel data) =
      _$LoadDraftOrderImpl;

  DraftOrderModel get data;
  @JsonKey(ignore: true)
  _$$LoadDraftOrderImplCopyWith<_$LoadDraftOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ClearOrderImplCopyWith<$Res> {
  factory _$$ClearOrderImplCopyWith(
          _$ClearOrderImpl value, $Res Function(_$ClearOrderImpl) then) =
      __$$ClearOrderImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearOrderImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$ClearOrderImpl>
    implements _$$ClearOrderImplCopyWith<$Res> {
  __$$ClearOrderImplCopyWithImpl(
      _$ClearOrderImpl _value, $Res Function(_$ClearOrderImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$ClearOrderImpl implements _ClearOrder {
  const _$ClearOrderImpl();

  @override
  String toString() {
    return 'CheckoutEvent.clearOrder()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearOrderImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return clearOrder();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return clearOrder?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (clearOrder != null) {
      return clearOrder();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return clearOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return clearOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (clearOrder != null) {
      return clearOrder(this);
    }
    return orElse();
  }
}

abstract class _ClearOrder implements CheckoutEvent {
  const factory _ClearOrder() = _$ClearOrderImpl;
}

/// @nodoc
abstract class _$$SetOrderTypeImplCopyWith<$Res> {
  factory _$$SetOrderTypeImplCopyWith(
          _$SetOrderTypeImpl value, $Res Function(_$SetOrderTypeImpl) then) =
      __$$SetOrderTypeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String orderType});
}

/// @nodoc
class __$$SetOrderTypeImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$SetOrderTypeImpl>
    implements _$$SetOrderTypeImplCopyWith<$Res> {
  __$$SetOrderTypeImplCopyWithImpl(
      _$SetOrderTypeImpl _value, $Res Function(_$SetOrderTypeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderType = null,
  }) {
    return _then(_$SetOrderTypeImpl(
      null == orderType
          ? _value.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SetOrderTypeImpl implements _SetOrderType {
  const _$SetOrderTypeImpl(this.orderType);

  @override
  final String orderType;

  @override
  String toString() {
    return 'CheckoutEvent.setOrderType(orderType: $orderType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetOrderTypeImpl &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SetOrderTypeImplCopyWith<_$SetOrderTypeImpl> get copyWith =>
      __$$SetOrderTypeImplCopyWithImpl<_$SetOrderTypeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return setOrderType(orderType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return setOrderType?.call(orderType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (setOrderType != null) {
      return setOrderType(orderType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return setOrderType(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return setOrderType?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (setOrderType != null) {
      return setOrderType(this);
    }
    return orElse();
  }
}

abstract class _SetOrderType implements CheckoutEvent {
  const factory _SetOrderType(final String orderType) = _$SetOrderTypeImpl;

  String get orderType;
  @JsonKey(ignore: true)
  _$$SetOrderTypeImplCopyWith<_$SetOrderTypeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateItemVariantsImplCopyWith<$Res> {
  factory _$$UpdateItemVariantsImplCopyWith(_$UpdateItemVariantsImpl value,
          $Res Function(_$UpdateItemVariantsImpl) then) =
      __$$UpdateItemVariantsImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {Product product,
      List<ProductVariant>? oldVariants,
      List<ProductVariant> newVariants});
}

/// @nodoc
class __$$UpdateItemVariantsImplCopyWithImpl<$Res>
    extends _$CheckoutEventCopyWithImpl<$Res, _$UpdateItemVariantsImpl>
    implements _$$UpdateItemVariantsImplCopyWith<$Res> {
  __$$UpdateItemVariantsImplCopyWithImpl(_$UpdateItemVariantsImpl _value,
      $Res Function(_$UpdateItemVariantsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? product = null,
    Object? oldVariants = freezed,
    Object? newVariants = null,
  }) {
    return _then(_$UpdateItemVariantsImpl(
      null == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as Product,
      freezed == oldVariants
          ? _value._oldVariants
          : oldVariants // ignore: cast_nullable_to_non_nullable
              as List<ProductVariant>?,
      null == newVariants
          ? _value._newVariants
          : newVariants // ignore: cast_nullable_to_non_nullable
              as List<ProductVariant>,
    ));
  }
}

/// @nodoc

class _$UpdateItemVariantsImpl implements _UpdateItemVariants {
  const _$UpdateItemVariantsImpl(
      this.product,
      final List<ProductVariant>? oldVariants,
      final List<ProductVariant> newVariants)
      : _oldVariants = oldVariants,
        _newVariants = newVariants;

  @override
  final Product product;
  final List<ProductVariant>? _oldVariants;
  @override
  List<ProductVariant>? get oldVariants {
    final value = _oldVariants;
    if (value == null) return null;
    if (_oldVariants is EqualUnmodifiableListView) return _oldVariants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<ProductVariant> _newVariants;
  @override
  List<ProductVariant> get newVariants {
    if (_newVariants is EqualUnmodifiableListView) return _newVariants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_newVariants);
  }

  @override
  String toString() {
    return 'CheckoutEvent.updateItemVariants(product: $product, oldVariants: $oldVariants, newVariants: $newVariants)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateItemVariantsImpl &&
            (identical(other.product, product) || other.product == product) &&
            const DeepCollectionEquality()
                .equals(other._oldVariants, _oldVariants) &&
            const DeepCollectionEquality()
                .equals(other._newVariants, _newVariants));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      product,
      const DeepCollectionEquality().hash(_oldVariants),
      const DeepCollectionEquality().hash(_newVariants));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateItemVariantsImplCopyWith<_$UpdateItemVariantsImpl> get copyWith =>
      __$$UpdateItemVariantsImplCopyWithImpl<_$UpdateItemVariantsImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() started,
    required TResult Function(Product product) addItem,
    required TResult Function(Product product) removeItem,
    required TResult Function(Discount discount) addDiscount,
    required TResult Function() removeDiscount,
    required TResult Function(int tax) addTax,
    required TResult Function(int serviceCharge) addServiceCharge,
    required TResult Function() removeTax,
    required TResult Function() removeServiceCharge,
    required TResult Function(
            int tableNumber, String draftName, int discountAmount)
        saveDraftOrder,
    required TResult Function(DraftOrderModel data) loadDraftOrder,
    required TResult Function() clearOrder,
    required TResult Function(String orderType) setOrderType,
    required TResult Function(Product product,
            List<ProductVariant>? oldVariants, List<ProductVariant> newVariants)
        updateItemVariants,
  }) {
    return updateItemVariants(product, oldVariants, newVariants);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? started,
    TResult? Function(Product product)? addItem,
    TResult? Function(Product product)? removeItem,
    TResult? Function(Discount discount)? addDiscount,
    TResult? Function()? removeDiscount,
    TResult? Function(int tax)? addTax,
    TResult? Function(int serviceCharge)? addServiceCharge,
    TResult? Function()? removeTax,
    TResult? Function()? removeServiceCharge,
    TResult? Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult? Function(DraftOrderModel data)? loadDraftOrder,
    TResult? Function()? clearOrder,
    TResult? Function(String orderType)? setOrderType,
    TResult? Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
  }) {
    return updateItemVariants?.call(product, oldVariants, newVariants);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? started,
    TResult Function(Product product)? addItem,
    TResult Function(Product product)? removeItem,
    TResult Function(Discount discount)? addDiscount,
    TResult Function()? removeDiscount,
    TResult Function(int tax)? addTax,
    TResult Function(int serviceCharge)? addServiceCharge,
    TResult Function()? removeTax,
    TResult Function()? removeServiceCharge,
    TResult Function(int tableNumber, String draftName, int discountAmount)?
        saveDraftOrder,
    TResult Function(DraftOrderModel data)? loadDraftOrder,
    TResult Function()? clearOrder,
    TResult Function(String orderType)? setOrderType,
    TResult Function(Product product, List<ProductVariant>? oldVariants,
            List<ProductVariant> newVariants)?
        updateItemVariants,
    required TResult orElse(),
  }) {
    if (updateItemVariants != null) {
      return updateItemVariants(product, oldVariants, newVariants);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(_AddItem value) addItem,
    required TResult Function(_RemoveItem value) removeItem,
    required TResult Function(_AddDiscount value) addDiscount,
    required TResult Function(_RemoveDiscount value) removeDiscount,
    required TResult Function(_AddTax value) addTax,
    required TResult Function(_AddServiceCharge value) addServiceCharge,
    required TResult Function(_RemoveTax value) removeTax,
    required TResult Function(_RemoveServiceCharge value) removeServiceCharge,
    required TResult Function(_SaveDraftOrder value) saveDraftOrder,
    required TResult Function(_LoadDraftOrder value) loadDraftOrder,
    required TResult Function(_ClearOrder value) clearOrder,
    required TResult Function(_SetOrderType value) setOrderType,
    required TResult Function(_UpdateItemVariants value) updateItemVariants,
  }) {
    return updateItemVariants(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(_AddItem value)? addItem,
    TResult? Function(_RemoveItem value)? removeItem,
    TResult? Function(_AddDiscount value)? addDiscount,
    TResult? Function(_RemoveDiscount value)? removeDiscount,
    TResult? Function(_AddTax value)? addTax,
    TResult? Function(_AddServiceCharge value)? addServiceCharge,
    TResult? Function(_RemoveTax value)? removeTax,
    TResult? Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult? Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult? Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult? Function(_ClearOrder value)? clearOrder,
    TResult? Function(_SetOrderType value)? setOrderType,
    TResult? Function(_UpdateItemVariants value)? updateItemVariants,
  }) {
    return updateItemVariants?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(_AddItem value)? addItem,
    TResult Function(_RemoveItem value)? removeItem,
    TResult Function(_AddDiscount value)? addDiscount,
    TResult Function(_RemoveDiscount value)? removeDiscount,
    TResult Function(_AddTax value)? addTax,
    TResult Function(_AddServiceCharge value)? addServiceCharge,
    TResult Function(_RemoveTax value)? removeTax,
    TResult Function(_RemoveServiceCharge value)? removeServiceCharge,
    TResult Function(_SaveDraftOrder value)? saveDraftOrder,
    TResult Function(_LoadDraftOrder value)? loadDraftOrder,
    TResult Function(_ClearOrder value)? clearOrder,
    TResult Function(_SetOrderType value)? setOrderType,
    TResult Function(_UpdateItemVariants value)? updateItemVariants,
    required TResult orElse(),
  }) {
    if (updateItemVariants != null) {
      return updateItemVariants(this);
    }
    return orElse();
  }
}

abstract class _UpdateItemVariants implements CheckoutEvent {
  const factory _UpdateItemVariants(
      final Product product,
      final List<ProductVariant>? oldVariants,
      final List<ProductVariant> newVariants) = _$UpdateItemVariantsImpl;

  Product get product;
  List<ProductVariant>? get oldVariants;
  List<ProductVariant> get newVariants;
  @JsonKey(ignore: true)
  _$$UpdateItemVariantsImplCopyWith<_$UpdateItemVariantsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CheckoutState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)
        loaded,
    required TResult Function(String message) error,
    required TResult Function(int orderId) savedDraftOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult? Function(String message)? error,
    TResult? Function(int orderId)? savedDraftOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult Function(String message)? error,
    TResult Function(int orderId)? savedDraftOrder,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_SavedDraftOrder value) savedDraftOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_SavedDraftOrder value)? savedDraftOrder,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_SavedDraftOrder value)? savedDraftOrder,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutStateCopyWith<$Res> {
  factory $CheckoutStateCopyWith(
          CheckoutState value, $Res Function(CheckoutState) then) =
      _$CheckoutStateCopyWithImpl<$Res, CheckoutState>;
}

/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res, $Val extends CheckoutState>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'CheckoutState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)
        loaded,
    required TResult Function(String message) error,
    required TResult Function(int orderId) savedDraftOrder,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult? Function(String message)? error,
    TResult? Function(int orderId)? savedDraftOrder,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult Function(String message)? error,
    TResult Function(int orderId)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_SavedDraftOrder value) savedDraftOrder,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_SavedDraftOrder value)? savedDraftOrder,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_SavedDraftOrder value)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements CheckoutState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'CheckoutState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)
        loaded,
    required TResult Function(String message) error,
    required TResult Function(int orderId) savedDraftOrder,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult? Function(String message)? error,
    TResult? Function(int orderId)? savedDraftOrder,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult Function(String message)? error,
    TResult Function(int orderId)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_SavedDraftOrder value) savedDraftOrder,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_SavedDraftOrder value)? savedDraftOrder,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_SavedDraftOrder value)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements CheckoutState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<ProductQuantity> items,
      Discount? discountModel,
      int discount,
      int discountAmount,
      int tax,
      int serviceCharge,
      int totalQuantity,
      int totalPrice,
      String draftName,
      String? orderType});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? discountModel = freezed,
    Object? discount = null,
    Object? discountAmount = null,
    Object? tax = null,
    Object? serviceCharge = null,
    Object? totalQuantity = null,
    Object? totalPrice = null,
    Object? draftName = null,
    Object? orderType = freezed,
  }) {
    return _then(_$LoadedImpl(
      null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ProductQuantity>,
      freezed == discountModel
          ? _value.discountModel
          : discountModel // ignore: cast_nullable_to_non_nullable
              as Discount?,
      null == discount
          ? _value.discount
          : discount // ignore: cast_nullable_to_non_nullable
              as int,
      null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as int,
      null == tax
          ? _value.tax
          : tax // ignore: cast_nullable_to_non_nullable
              as int,
      null == serviceCharge
          ? _value.serviceCharge
          : serviceCharge // ignore: cast_nullable_to_non_nullable
              as int,
      null == totalQuantity
          ? _value.totalQuantity
          : totalQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      null == totalPrice
          ? _value.totalPrice
          : totalPrice // ignore: cast_nullable_to_non_nullable
              as int,
      null == draftName
          ? _value.draftName
          : draftName // ignore: cast_nullable_to_non_nullable
              as String,
      freezed == orderType
          ? _value.orderType
          : orderType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(
      final List<ProductQuantity> items,
      this.discountModel,
      this.discount,
      this.discountAmount,
      this.tax,
      this.serviceCharge,
      this.totalQuantity,
      this.totalPrice,
      this.draftName,
      this.orderType)
      : _items = items;

  final List<ProductQuantity> _items;
  @override
  List<ProductQuantity> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final Discount? discountModel;
  @override
  final int discount;
  @override
  final int discountAmount;
  @override
  final int tax;
  @override
  final int serviceCharge;
  @override
  final int totalQuantity;
  @override
  final int totalPrice;
  @override
  final String draftName;
  @override
  final String? orderType;

  @override
  String toString() {
    return 'CheckoutState.loaded(items: $items, discountModel: $discountModel, discount: $discount, discountAmount: $discountAmount, tax: $tax, serviceCharge: $serviceCharge, totalQuantity: $totalQuantity, totalPrice: $totalPrice, draftName: $draftName, orderType: $orderType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.discountModel, discountModel) ||
                other.discountModel == discountModel) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.tax, tax) || other.tax == tax) &&
            (identical(other.serviceCharge, serviceCharge) ||
                other.serviceCharge == serviceCharge) &&
            (identical(other.totalQuantity, totalQuantity) ||
                other.totalQuantity == totalQuantity) &&
            (identical(other.totalPrice, totalPrice) ||
                other.totalPrice == totalPrice) &&
            (identical(other.draftName, draftName) ||
                other.draftName == draftName) &&
            (identical(other.orderType, orderType) ||
                other.orderType == orderType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      discountModel,
      discount,
      discountAmount,
      tax,
      serviceCharge,
      totalQuantity,
      totalPrice,
      draftName,
      orderType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)
        loaded,
    required TResult Function(String message) error,
    required TResult Function(int orderId) savedDraftOrder,
  }) {
    return loaded(items, discountModel, discount, discountAmount, tax,
        serviceCharge, totalQuantity, totalPrice, draftName, orderType);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult? Function(String message)? error,
    TResult? Function(int orderId)? savedDraftOrder,
  }) {
    return loaded?.call(items, discountModel, discount, discountAmount, tax,
        serviceCharge, totalQuantity, totalPrice, draftName, orderType);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult Function(String message)? error,
    TResult Function(int orderId)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(items, discountModel, discount, discountAmount, tax,
          serviceCharge, totalQuantity, totalPrice, draftName, orderType);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_SavedDraftOrder value) savedDraftOrder,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_SavedDraftOrder value)? savedDraftOrder,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_SavedDraftOrder value)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements CheckoutState {
  const factory _Loaded(
      final List<ProductQuantity> items,
      final Discount? discountModel,
      final int discount,
      final int discountAmount,
      final int tax,
      final int serviceCharge,
      final int totalQuantity,
      final int totalPrice,
      final String draftName,
      final String? orderType) = _$LoadedImpl;

  List<ProductQuantity> get items;
  Discount? get discountModel;
  int get discount;
  int get discountAmount;
  int get tax;
  int get serviceCharge;
  int get totalQuantity;
  int get totalPrice;
  String get draftName;
  String? get orderType;
  @JsonKey(ignore: true)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'CheckoutState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)
        loaded,
    required TResult Function(String message) error,
    required TResult Function(int orderId) savedDraftOrder,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult? Function(String message)? error,
    TResult? Function(int orderId)? savedDraftOrder,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult Function(String message)? error,
    TResult Function(int orderId)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_SavedDraftOrder value) savedDraftOrder,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_SavedDraftOrder value)? savedDraftOrder,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_SavedDraftOrder value)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements CheckoutState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SavedDraftOrderImplCopyWith<$Res> {
  factory _$$SavedDraftOrderImplCopyWith(_$SavedDraftOrderImpl value,
          $Res Function(_$SavedDraftOrderImpl) then) =
      __$$SavedDraftOrderImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int orderId});
}

/// @nodoc
class __$$SavedDraftOrderImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$SavedDraftOrderImpl>
    implements _$$SavedDraftOrderImplCopyWith<$Res> {
  __$$SavedDraftOrderImplCopyWithImpl(
      _$SavedDraftOrderImpl _value, $Res Function(_$SavedDraftOrderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? orderId = null,
  }) {
    return _then(_$SavedDraftOrderImpl(
      null == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$SavedDraftOrderImpl implements _SavedDraftOrder {
  const _$SavedDraftOrderImpl(this.orderId);

  @override
  final int orderId;

  @override
  String toString() {
    return 'CheckoutState.savedDraftOrder(orderId: $orderId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavedDraftOrderImpl &&
            (identical(other.orderId, orderId) || other.orderId == orderId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, orderId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SavedDraftOrderImplCopyWith<_$SavedDraftOrderImpl> get copyWith =>
      __$$SavedDraftOrderImplCopyWithImpl<_$SavedDraftOrderImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)
        loaded,
    required TResult Function(String message) error,
    required TResult Function(int orderId) savedDraftOrder,
  }) {
    return savedDraftOrder(orderId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult? Function(String message)? error,
    TResult? Function(int orderId)? savedDraftOrder,
  }) {
    return savedDraftOrder?.call(orderId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<ProductQuantity> items,
            Discount? discountModel,
            int discount,
            int discountAmount,
            int tax,
            int serviceCharge,
            int totalQuantity,
            int totalPrice,
            String draftName,
            String? orderType)?
        loaded,
    TResult Function(String message)? error,
    TResult Function(int orderId)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (savedDraftOrder != null) {
      return savedDraftOrder(orderId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
    required TResult Function(_SavedDraftOrder value) savedDraftOrder,
  }) {
    return savedDraftOrder(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
    TResult? Function(_SavedDraftOrder value)? savedDraftOrder,
  }) {
    return savedDraftOrder?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    TResult Function(_SavedDraftOrder value)? savedDraftOrder,
    required TResult orElse(),
  }) {
    if (savedDraftOrder != null) {
      return savedDraftOrder(this);
    }
    return orElse();
  }
}

abstract class _SavedDraftOrder implements CheckoutState {
  const factory _SavedDraftOrder(final int orderId) = _$SavedDraftOrderImpl;

  int get orderId;
  @JsonKey(ignore: true)
  _$$SavedDraftOrderImplCopyWith<_$SavedDraftOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
