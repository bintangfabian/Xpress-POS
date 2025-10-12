part of 'status_table_bloc.dart';

@freezed
class StatusTableEvent with _$StatusTableEvent {
  const factory StatusTableEvent.started() = _Started;
  const factory StatusTableEvent.statusTabel(
    TableModel table,
  ) = _StatusTable;
}
