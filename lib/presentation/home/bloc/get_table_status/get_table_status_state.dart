part of 'get_table_status_bloc.dart';

@freezed
class GetTableStatusState with _$GetTableStatusState {
  const factory GetTableStatusState.initial() = _Initial;
  const factory GetTableStatusState.loading() = _Loading;
  const factory GetTableStatusState.success(List<TableModel> tables) = _Success;
}
