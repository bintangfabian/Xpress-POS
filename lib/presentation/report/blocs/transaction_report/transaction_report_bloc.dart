
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/models/response/order_remote_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_report_event.dart';
part 'transaction_report_state.dart';
part 'transaction_report_bloc.freezed.dart';

class TransactionReportBloc
    extends Bloc<TransactionReportEvent, TransactionReportState> {
  final OrderRemoteDatasource datasource;
  TransactionReportBloc(this.datasource) : super(const _Initial()) {
    on<_GetReport>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getOrderByRangeDate(
        event.startDate,
        event.endDate,
      );

      result.fold((l) => emit(_Error(l)), (r) => emit(_Loaded(r.data!)));
    });
  }
}
