import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/sales_remote_datasource.dart';
import 'best_sellers_event.dart';
import 'best_sellers_state.dart';

class BestSellersBloc extends Bloc<BestSellersEvent, BestSellersState> {
  final SalesRemoteDataSource _dataSource;

  BestSellersBloc(this._dataSource) : super(BestSellersInitial()) {
    on<GetBestSellers>(_onGetBestSellers);
  }

  Future<void> _onGetBestSellers(
    GetBestSellers event,
    Emitter<BestSellersState> emit,
  ) async {
    emit(BestSellersLoading());
    final result = await _dataSource.getBestSellers(
      startDate: event.startDate,
      endDate: event.endDate,
      limit: event.limit,
    );
    result.fold(
      (error) => emit(BestSellersError(error)),
      (data) => emit(BestSellersSuccess(data)),
    );
  }
}
