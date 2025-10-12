part of 'get_table_status_bloc.dart';

@freezed
class GetTableStatusEvent with _$GetTableStatusEvent {
  const factory GetTableStatusEvent.started() = _Started;

  const factory GetTableStatusEvent.getTablesStatus(String status) =
      _GetTablesStatus;
}
