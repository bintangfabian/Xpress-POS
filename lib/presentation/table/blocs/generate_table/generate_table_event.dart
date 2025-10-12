part of 'generate_table_bloc.dart';

@freezed
class GenerateTableEvent with _$GenerateTableEvent {
  const factory GenerateTableEvent.started() = _Started;
  const factory GenerateTableEvent.generate(int count) = _Generate;
}
