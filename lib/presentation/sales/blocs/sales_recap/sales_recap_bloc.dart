import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/sales_remote_datasource.dart';
import 'sales_recap_event.dart';
import 'sales_recap_state.dart';

class SalesRecapBloc extends Bloc<SalesRecapEvent, SalesRecapState> {
  final SalesRemoteDataSource _dataSource;

  SalesRecapBloc(this._dataSource) : super(SalesRecapInitial()) {
    on<GetSalesRecap>(_onGetSalesRecap);
  }

  Future<void> _onGetSalesRecap(
    GetSalesRecap event,
    Emitter<SalesRecapState> emit,
  ) async {
    emit(SalesRecapLoading());
    final result = await _dataSource.getSalesRecap(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (error) => emit(SalesRecapError(error)),
      (data) => emit(SalesRecapSuccess(data)),
    );
  }
}
