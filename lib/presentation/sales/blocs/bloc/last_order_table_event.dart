part of 'last_order_table_bloc.dart';

@freezed
class LastOrderTableEvent with _$LastOrderTableEvent {
  const factory LastOrderTableEvent.started() = _Started;
  const factory LastOrderTableEvent.lastOrderTable(int tableNumber) =
      _LastOrderTable;
}
