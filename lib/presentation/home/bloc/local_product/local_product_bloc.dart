import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:xpress/data/datasources/product_remote_datasource.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';

import '../../../../data/models/response/product_response_model.dart';

part 'local_product_bloc.freezed.dart';
part 'local_product_event.dart';
part 'local_product_state.dart';

class LocalProductBloc extends Bloc<LocalProductEvent, LocalProductState> {
  final ProductRemoteDatasource productRemoteDatasource;
  final ProductLocalDatasource productLocalDatasource;

  LocalProductBloc(
    this.productRemoteDatasource,
    this.productLocalDatasource,
  ) : super(const _Initial()) {
    on<_GetLocalProduct>((event, emit) async {
      emit(const _Loading());

      // ✅ Load products directly from API without saving to local database
      final result = await productRemoteDatasource.getProducts();

      result.fold(
        (error) {
          // If API fails, return empty list
          emit(_Loaded(const []));
        },
        (response) {
          // ✅ Use products directly from API response, no local save
          final products = response.data ?? <Product>[];
          emit(_Loaded(products));
        },
      );
    });
  }
}
