import 'package:xpress/data/datasources/category_local_datasource.dart';
import 'package:xpress/data/datasources/category_remote_datasource.dart';
import 'package:xpress/data/models/response/category_response_model.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

class CategoryRepository {
  CategoryRepository({
    required CategoryRemoteDatasource remoteDatasource,
    required CategoryLocalDatasource localDatasource,
    required OnlineCheckerBloc onlineCheckerBloc,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _onlineCheckerBloc = onlineCheckerBloc;

  final CategoryRemoteDatasource _remoteDatasource;
  final CategoryLocalDatasource _localDatasource;
  final OnlineCheckerBloc _onlineCheckerBloc;

  Future<List<CategoryModel>> getCategories() async {
    // Try to sync from server if online
    if (_onlineCheckerBloc.isOnline) {
      final remoteResult = await _remoteDatasource.getCategories();
      await remoteResult.fold(
        (failure) async {
          // Swallow failure and fall back to local cache
        },
        (response) async {
          final categories = response.data;
          await _localDatasource.saveCategories(categories);
        },
      );
    }

    // Always return from local
    return _localDatasource.getCategories();
  }
}
