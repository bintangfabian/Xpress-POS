part of 'summary_bloc.dart';

@freezed
class SummaryEvent with _$SummaryEvent {
  const factory SummaryEvent.started() = _Started;
  const factory SummaryEvent.getSummary(String startDate, String endDate) =
      _GetSummary;
}
