part of 'last_order_table_bloc.dart';

@freezed
class LastOrderTableState with _$LastOrderTableState {
  const factory LastOrderTableState.initial() = _Initial;
  const factory LastOrderTableState.loading() = _Loading;
  const factory LastOrderTableState.success(OrderModel? order) = _Success;
}
