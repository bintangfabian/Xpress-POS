import 'package:xpress/data/datasources/discount_local_datasource.dart';
import 'package:xpress/data/datasources/discount_remote_datasource.dart';
import 'package:xpress/data/models/response/discount_response_model.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

class DiscountRepository {
  DiscountRepository({
    required DiscountRemoteDatasource remoteDatasource,
    required DiscountLocalDatasource localDatasource,
    required OnlineCheckerBloc onlineCheckerBloc,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _onlineCheckerBloc = onlineCheckerBloc;

  final DiscountRemoteDatasource _remoteDatasource;
  final DiscountLocalDatasource _localDatasource;
  final OnlineCheckerBloc _onlineCheckerBloc;

  Future<List<Discount>> getDiscounts() async {
    // Try to sync from server if online
    if (_onlineCheckerBloc.isOnline) {
      final remoteResult = await _remoteDatasource.getDiscounts();
      await remoteResult.fold(
        (failure) async {
          // Swallow failure and fall back to local cache
        },
        (response) async {
          final discounts = response.data ?? [];
          await _localDatasource.saveDiscounts(discounts);
        },
      );
    }

    // Always return from local
    return _localDatasource.getDiscounts();
  }

  Future<List<Discount>> getActiveDiscounts() async {
    // Try to sync from server if online
    if (_onlineCheckerBloc.isOnline) {
      await getDiscounts(); // This will sync and save
    }

    // Always return from local
    return _localDatasource.getActiveDiscounts();
  }
}
