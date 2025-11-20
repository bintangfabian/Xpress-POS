import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/models/response/summary_response_model.dart';
import 'package:xpress/data/repositories/report_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'summary_event.dart';
part 'summary_state.dart';
part 'summary_bloc.freezed.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final ReportRepository repository;
  SummaryBloc(
    this.repository,
  ) : super(const _Initial()) {
    on<_GetSummary>((event, emit) async {
      emit(const _Loading());
      final result = await repository.getSummaryByDateRange(
          event.startDate, event.endDate);
      result.fold((l) => emit(_Error(l)), (r) => emit(_Success(r.data!)));
    });
  }
}
