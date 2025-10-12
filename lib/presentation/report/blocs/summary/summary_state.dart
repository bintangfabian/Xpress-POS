part of 'summary_bloc.dart';

@freezed
class SummaryState with _$SummaryState {
  const factory SummaryState.initial() = _Initial;
  const factory SummaryState.loading() = _Loading;
  const factory SummaryState.success(SummaryModel summary) = _Success;
  const factory SummaryState.error(String message) = _Error;
}
