import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/sales_remote_datasource.dart';
import 'cash_session_history_event.dart';
import 'cash_session_history_state.dart';

class CashSessionHistoryBloc
    extends Bloc<CashSessionHistoryEvent, CashSessionHistoryState> {
  final SalesRemoteDataSource _dataSource;

  CashSessionHistoryBloc(this._dataSource)
      : super(CashSessionHistoryInitial()) {
    on<GetCashSessions>(_onGetCashSessions);
    on<GetCashSessionDetail>(_onGetCashSessionDetail);
  }

  Future<void> _onGetCashSessions(
    GetCashSessions event,
    Emitter<CashSessionHistoryState> emit,
  ) async {
    emit(CashSessionHistoryLoading());
    final result = await _dataSource.getCashSessions(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (error) => emit(CashSessionHistoryError(error)),
      (sessions) => emit(CashSessionsSuccess(sessions)),
    );
  }

  Future<void> _onGetCashSessionDetail(
    GetCashSessionDetail event,
    Emitter<CashSessionHistoryState> emit,
  ) async {
    emit(CashSessionHistoryLoading());
    final result = await _dataSource.getCashSessionDetail(event.sessionId);
    result.fold(
      (error) => emit(CashSessionHistoryError(error)),
      (session) => emit(CashSessionDetailSuccess(session)),
    );
  }
}
