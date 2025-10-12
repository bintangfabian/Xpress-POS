import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:xpress/data/datasources/product_remote_datasource.dart';
import 'package:xpress/data/models/response/product_response_model.dart';

part 'sync_product_bloc.freezed.dart';
part 'sync_product_event.dart';
part 'sync_product_state.dart';

class SyncProductBloc extends Bloc<SyncProductEvent, SyncProductState> {
  final ProductRemoteDatasource productRemoteDatasource;
  SyncProductBloc(
    this.productRemoteDatasource,
  ) : super(const _Initial()) {
    on<_SyncProduct>((event, emit) async{
      emit(const _Loading());
      final result = await productRemoteDatasource.getProducts();
      result.fold(
        (l) => emit(_Error(l)),
        (r) => emit(_Loaded(r)),
      );
    });
  }
}
