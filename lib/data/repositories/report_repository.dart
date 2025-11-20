import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import 'package:xpress/core/utils/timezone_helper.dart';
import 'package:xpress/data/datasources/local/dao/order_dao.dart';
import 'package:xpress/data/datasources/local/dao/product_dao.dart';
import 'package:xpress/data/datasources/local/database/database.dart' as drift;
import 'package:xpress/data/datasources/order_remote_datasource.dart';
import 'package:xpress/data/models/response/order_response_model.dart';
import 'package:xpress/data/models/response/summary_response_model.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

void _logDebug(String message) {
  assert(() {
    developer.log(message, name: 'ReportRepository');
    return true;
  }());
}

class ReportRepository {
  ReportRepository({
    required OrderRemoteDatasource remoteDatasource,
    required drift.AppDatabase database,
    required OnlineCheckerBloc onlineCheckerBloc,
  })  : _remoteDatasource = remoteDatasource,
        _orderDao = OrderDao(database),
        _productDao = ProductDao(database),
        _onlineCheckerBloc = onlineCheckerBloc;

  final OrderRemoteDatasource _remoteDatasource;
  final OrderDao _orderDao;
  final ProductDao _productDao;
  final OnlineCheckerBloc _onlineCheckerBloc;

  /// Get orders by date range - works offline by aggregating from local database
  /// [syncStatusFilter] - 'synced' for online transactions, 'pending' for offline transactions, null for all
  Future<Either<String, OrderResponseModel>> getOrdersByDateRange(
    String startDate,
    String endDate, {
    int perPage = 1000,
    int page = 1,
    String? syncStatusFilter,
  }) async {
    try {
      // ✅ For offline transactions (pending), always use local database
      // ✅ For online transactions (synced), try server first if online
      if (syncStatusFilter == 'synced' && _onlineCheckerBloc.isOnline) {
        final remoteResult = await _remoteDatasource.getOrderByRangeDate(
          startDate,
          endDate,
          perPage: perPage,
          page: page,
        );
        // If successful, data is already in local database via sync
        if (remoteResult.isRight()) {
          return remoteResult;
        }
      }
      // For pending orders or if remote fetch fails, use local database

      // Aggregate from local database
      // Parse dates and convert to WIB timezone for comparison
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      // Convert to WIB timezone for accurate comparison
      final startWib = TimezoneHelper.toWib(start);
      final endWib = TimezoneHelper.toWib(end);

      // Set start to beginning of day and end to end of day in WIB
      final startOfDay = DateTime(startWib.year, startWib.month, startWib.day);
      final endOfDay =
          DateTime(endWib.year, endWib.month, endWib.day, 23, 59, 59);

      final localOrders = await _orderDao.getAllOrders();

      _logDebug(
          'ReportRepository: Checking ${localOrders.length} total orders for date range $startDate to $endDate');
      _logDebug(
          'ReportRepository: Date range in WIB: ${startOfDay.toIso8601String()} to ${endOfDay.toIso8601String()}');

      // Filter by date range, sync status, and not deleted
      // syncStatusFilter: 'synced' = online transactions, 'pending' = offline transactions, null = all
      final filteredOrders = localOrders.where((order) {
        // Order dates are stored in UTC, convert to WIB for comparison
        final orderDateWib = TimezoneHelper.toWib(order.updatedAt);

        // Check if order date is within the date range (inclusive)
        final isAfterStart = orderDateWib
            .isAfter(startOfDay.subtract(const Duration(seconds: 1)));
        final isBeforeEnd =
            orderDateWib.isBefore(endOfDay.add(const Duration(seconds: 1)));
        final isNotDeleted = !order.isDeleted;

        // Filter by sync status if specified
        final matchesSyncStatus =
            syncStatusFilter == null || order.syncStatus == syncStatusFilter;

        if (isAfterStart && isBeforeEnd && isNotDeleted && matchesSyncStatus) {
          _logDebug(
              'ReportRepository: Order ${order.uuid} matches (date: ${orderDateWib.toIso8601String()}, status: ${order.syncStatus}, filter: $syncStatusFilter)');
        }

        return isAfterStart && isBeforeEnd && isNotDeleted && matchesSyncStatus;
      }).toList();

      _logDebug(
          'ReportRepository: Found ${localOrders.length} total orders, ${filteredOrders.length} in date range $startDate to $endDate');

      // Convert to ItemOrder format
      final itemOrders = await Future.wait(
        filteredOrders.map((order) async {
          final driftItems = await _orderDao.getItemsByOrder(order.uuid);
          return _convertOrderToItemOrder(order, driftItems);
        }),
      );

      return Right(OrderResponseModel(
        status: 'success',
        data: itemOrders,
        meta: OrderResponseMeta(
          currentPage: page,
          lastPage: 1,
          perPage: perPage,
          total: itemOrders.length,
          hasMore: false,
        ),
      ));
    } catch (e) {
      return Left('Failed to get orders: $e');
    }
  }

  /// Get summary by date range - works offline by aggregating from local database
  /// [syncStatusFilter] - 'synced' for online transactions, 'pending' for offline transactions, null for all
  Future<Either<String, SummaryResponseModel>> getSummaryByDateRange(
    String startDate,
    String endDate, {
    String? syncStatusFilter,
  }) async {
    try {
      // Try to sync from server if online
      if (_onlineCheckerBloc.isOnline) {
        final remoteResult = await _remoteDatasource.getSummaryByRangeDate(
          startDate,
          endDate,
        );
        if (remoteResult.isRight()) {
          return remoteResult;
        }
      }

      // Aggregate from local database
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      // Set start to beginning of day and end to end of day
      final startOfDay = DateTime(start.year, start.month, start.day);
      final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

      final localOrders = await _orderDao.getAllOrders();

      // Filter by date range and not deleted
      // Include all orders (pending, synced, etc.) - they should all appear in report
      final filteredOrders = localOrders.where((order) {
        final orderDate = order.updatedAt;
        // Check if order date is within the date range (inclusive)
        final isAfterStart =
            orderDate.isAfter(startOfDay.subtract(const Duration(seconds: 1)));
        final isBeforeEnd =
            orderDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
        return isAfterStart && isBeforeEnd && !order.isDeleted;
      }).toList();

      _logDebug(
          'ReportRepository Summary: Found ${localOrders.length} total orders, ${filteredOrders.length} in date range $startDate to $endDate');

      // Calculate summary
      double totalRevenue = 0;
      double totalDiscount = 0;
      double totalTax = 0;
      double totalSubtotal = 0;
      double totalServiceCharge = 0;

      for (final order in filteredOrders) {
        totalRevenue += order.total;
        totalDiscount += order.discountAmount;
        totalSubtotal += order.subtotal;
        totalServiceCharge += order.serviceCharge;
        // Tax is usually calculated from subtotal, estimate if not available
        totalTax += order.total -
            order.subtotal -
            order.serviceCharge +
            order.discountAmount;
      }

      final summary = SummaryModel(
        totalRevenue: totalRevenue.toStringAsFixed(2),
        totalDiscount: totalDiscount.toStringAsFixed(2),
        totalTax: totalTax.toStringAsFixed(2),
        totalSubtotal: totalSubtotal.toStringAsFixed(2),
        totalServiceCharge: totalServiceCharge.toStringAsFixed(2),
        total: totalRevenue.toInt(),
      );

      return Right(SummaryResponseModel(
        status: 'success',
        data: summary,
      ));
    } catch (e) {
      return Left('Failed to get summary: $e');
    }
  }

  /// Convert Drift Order to ItemOrder format
  Future<ItemOrder> _convertOrderToItemOrder(
    drift.Order order,
    List<drift.OrderItem> driftOrderItems,
  ) async {
    // Get product details for each item
    final itemDetails = await Future.wait(
      driftOrderItems.map((item) async {
        final product = await _productDao.getByUuid(item.productUuid);
        return OrderItem(
          id: item.id.toString(),
          productId: int.tryParse(product?.serverId ?? ''),
          productName: product?.name ?? 'Unknown Product',
          quantity: item.quantity,
          unitPrice: item.price.toInt().toString(),
          totalPrice: (item.price * item.quantity).toInt().toString(),
          createdAt: item.updatedAt,
          updatedAt: item.updatedAt,
        );
      }),
    );

    final taxAmount = (order.total -
            order.subtotal -
            order.serviceCharge +
            order.discountAmount)
        .toInt();

    return ItemOrder(
      id: order.serverId ?? order.uuid,
      orderNumber: order.serverId ?? order.uuid,
      totalAmount: order.total.toInt().toString(),
      subtotal: order.subtotal.toInt().toString(),
      taxAmount: taxAmount.toString(),
      discountAmount: order.discountAmount.toInt().toString(),
      serviceCharge: order.serviceCharge.toInt().toString(),
      paymentMethod: order.paymentMethod ?? '',
      status: order.status,
      items: itemDetails,
      createdAt: order.updatedAt,
      updatedAt: order.updatedAt,
      notes: order.notes,
    );
  }
}
