import 'package:bloc/bloc.dart';
import 'package:xpress/data/models/response/item_sales_response_model.dart';
import 'package:xpress/data/datasources/order_item_remote_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_sales_report_event.dart';
part 'item_sales_report_state.dart';
part 'item_sales_report_bloc.freezed.dart';

class ItemSalesReportBloc
    extends Bloc<ItemSalesReportEvent, ItemSalesReportState> {
  final OrderItemRemoteDatasource datasource;
  ItemSalesReportBloc(this.datasource) : super(const _Initial()) {
    on<_GetItemSales>((event, emit) async {
      emit(const _Loading());
      final result = await datasource.getItemSalesByRangeDate(
          event.startDate, event.endDate);
      result.fold((l) => emit(_Error(l)), (r) => emit(_Loaded(r.data!)));
    });
  }
}
