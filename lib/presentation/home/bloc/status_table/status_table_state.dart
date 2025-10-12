part of 'status_table_bloc.dart';

@freezed
class StatusTableState with _$StatusTableState {
  const factory StatusTableState.initial() = _Initial;
  const factory StatusTableState.loading() = _Loading;
  const factory StatusTableState.success() = _Success;
}
