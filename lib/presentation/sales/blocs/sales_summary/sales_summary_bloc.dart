import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/sales_remote_datasource.dart';
import 'sales_summary_event.dart';
import 'sales_summary_state.dart';

class SalesSummaryBloc extends Bloc<SalesSummaryEvent, SalesSummaryState> {
  final SalesRemoteDataSource _dataSource;

  SalesSummaryBloc(this._dataSource) : super(SalesSummaryInitial()) {
    on<GetSalesSummary>(_onGetSalesSummary);
  }

  Future<void> _onGetSalesSummary(
    GetSalesSummary event,
    Emitter<SalesSummaryState> emit,
  ) async {
    emit(SalesSummaryLoading());
    final result = await _dataSource.getSalesSummary(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (error) => emit(SalesSummaryError(error)),
      (data) => emit(SalesSummarySuccess(data)),
    );
  }
}
