part of 'get_products_bloc.dart';

@freezed
class GetProductsEvent with _$GetProductsEvent {
  const factory GetProductsEvent.started() = _Started;
  const factory GetProductsEvent.fetch() = _Fetch;
}
