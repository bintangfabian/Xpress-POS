import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/sales_remote_datasource.dart';
import 'cash_session_event.dart';
import 'cash_session_state.dart';

class CashSessionBloc extends Bloc<CashSessionEvent, CashSessionState> {
  final SalesRemoteDataSource _dataSource;

  CashSessionBloc(this._dataSource) : super(CashSessionInitial()) {
    on<GetCurrentCashSession>(_onGetCurrent);
    on<OpenCashSession>(_onOpenSession);
    on<CloseCashSession>(_onCloseSession);
    on<AddCashExpense>(_onAddExpense);
  }

  Future<void> _onGetCurrent(
    GetCurrentCashSession event,
    Emitter<CashSessionState> emit,
  ) async {
    emit(CashSessionLoading());
    final result = await _dataSource.getCurrentCashSession();
    result.fold(
      (error) => emit(CashSessionError(error)),
      (data) => emit(CashSessionSuccess(data)),
    );
  }

  Future<void> _onOpenSession(
    OpenCashSession event,
    Emitter<CashSessionState> emit,
  ) async {
    emit(CashSessionLoading());
    final result = await _dataSource.openCashSession(
      openingBalance: event.openingBalance,
    );
    result.fold(
      (error) => emit(CashSessionError(error)),
      (data) => emit(CashSessionSuccess(data)),
    );
  }

  Future<void> _onCloseSession(
    CloseCashSession event,
    Emitter<CashSessionState> emit,
  ) async {
    emit(CashSessionLoading());
    final result = await _dataSource.closeCashSession(
      sessionId: event.sessionId,
      closingBalance: event.closingBalance,
    );
    result.fold(
      (error) => emit(CashSessionError(error)),
      (data) => emit(CashSessionSuccess(data)),
    );
  }

  Future<void> _onAddExpense(
    AddCashExpense event,
    Emitter<CashSessionState> emit,
  ) async {
    final result = await _dataSource.addExpense(
      sessionId: event.sessionId,
      amount: event.amount,
      description: event.description,
      category: event.category,
    );

    result.fold(
      (error) => emit(CashSessionError(error)),
      (_) {
        // Refresh current session after adding expense
        add(GetCurrentCashSession());
      },
    );
  }
}
