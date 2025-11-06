import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:xpress/data/datasources/product_local_datasource.dart';

import '../../../../data/models/response/product_response_model.dart';

part 'local_product_bloc.freezed.dart';
part 'local_product_event.dart';
part 'local_product_state.dart';

class LocalProductBloc extends Bloc<LocalProductEvent, LocalProductState> {
  final ProductLocalDatasource productLocalDatasource;
  LocalProductBloc(
    this.productLocalDatasource,
  ) : super(const _Initial()) {
    on<_GetLocalProduct>((event, emit) async {
      print('[LocalProductBloc] Loading products from local database...');
      emit(const _Loading());
      final result = await productLocalDatasource.getProducts();
      print('[LocalProductBloc] Loaded ${result.length} products');

      // Debug: Check for duplicates
      final uniqueIds = result.map((p) => p.id).toSet();
      final uniqueProductIds = result.map((p) => p.productId).toSet();
      if (uniqueIds.length != result.length) {
        print('[LocalProductBloc] ⚠️ WARNING: Duplicate IDs detected!');
        print('   Total products: ${result.length}');
        print('   Unique IDs: ${uniqueIds.length}');
      }
      if (uniqueProductIds.length != result.length) {
        print('[LocalProductBloc] ⚠️ WARNING: Duplicate Product IDs detected!');
        print('   Total products: ${result.length}');
        print('   Unique Product IDs: ${uniqueProductIds.length}');
      }

      emit(_Loaded(result));
    });
  }
}
