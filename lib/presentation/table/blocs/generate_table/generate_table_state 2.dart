part of 'generate_table_bloc.dart';

@freezed
class GenerateTableState with _$GenerateTableState {
  const factory GenerateTableState.initial() = _Initial;
  const factory GenerateTableState.loading() = _Loading;
  const factory GenerateTableState.success(String message) = _Success;
  // Keep union minimal to avoid regeneration issues.
}
