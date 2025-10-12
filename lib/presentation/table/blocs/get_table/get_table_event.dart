part of 'get_table_bloc.dart';

@freezed
class GetTableEvent with _$GetTableEvent {
  const factory GetTableEvent.started() = _Started;
  const factory GetTableEvent.getTables() = _GetTables;
}
