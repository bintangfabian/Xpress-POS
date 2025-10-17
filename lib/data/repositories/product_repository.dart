import 'package:drift/drift.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

import '../datasources/local/dao/product_dao.dart';
import '../datasources/local/database/database.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/response/product_response_model.dart' as remote;

class ProductRepository {
  ProductRepository({
    required AppDatabase database,
    required ProductRemoteDatasource remoteDatasource,
    required OnlineCheckerBloc onlineCheckerBloc,
  })  : _remoteDatasource = remoteDatasource,
        _onlineCheckerBloc = onlineCheckerBloc,
        _productDao = ProductDao(database);

  final ProductRemoteDatasource _remoteDatasource;
  final OnlineCheckerBloc _onlineCheckerBloc;
  final ProductDao _productDao;

  Future<List<Product>> getProducts() async {
    if (_onlineCheckerBloc.isOnline) {
      final remoteResult = await _remoteDatasource.getProducts();
      await remoteResult.fold(
        (failure) async {
          // Swallow failure and fall back to local cache.
        },
        (response) async {
          final products = response.data ?? <remote.Product>[];
          final companions = products.map(_mapRemoteProduct).toList();
          await _productDao.insertOrUpdateProducts(companions);
        },
      );
    }

    return _productDao.getAllProducts();
  }

  Future<Product?> getProductByUuid(String uuid) async {
    final localProduct = await _productDao.getByUuid(uuid);
    if (localProduct != null) {
      return localProduct;
    }

    if (_onlineCheckerBloc.isOnline) {
      await getProducts();
      return _productDao.getByUuid(uuid);
    }

    return null;
  }

  ProductsCompanion _mapRemoteProduct(remote.Product product) {
    final serverId =
        product.productId?.toString() ?? product.id?.toString() ?? '';
    final uuid = serverId.isNotEmpty
        ? 'product-$serverId'
        : 'product-${TimezoneHelper.now().microsecondsSinceEpoch}';
    final price = _parseDouble(product.price);
    final cost = _parseDouble(product.price); // Fallback when cost is absent.

    return ProductsCompanion.insert(
      uuid: uuid,
      name: product.name ?? 'Produk Tanpa Nama',
      cost: cost,
      price: price,
      stock: Value(product.stock ?? 0),
      serverId: serverId.isEmpty ? const Value.absent() : Value(serverId),
      syncStatus: const Value('synced'),
      updatedAt: Value(product.updatedAt ?? TimezoneHelper.now()),
      isDeleted: const Value(false),
    );
  }

  double _parseDouble(String? value) {
    if (value == null) return 0;
    final cleaned = value.replaceAll(RegExp(r'[^0-9\.,-]'), '');
    return double.tryParse(cleaned.replaceAll(',', '.')) ?? 0;
  }
}
