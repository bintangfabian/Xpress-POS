import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_table_event.dart';
part 'status_table_state.dart';
part 'status_table_bloc.freezed.dart';

class StatusTableBloc extends Bloc<StatusTableEvent, StatusTableState> {
  final ProductLocalDatasource datasource;
  StatusTableBloc(this.datasource) : super(StatusTableState.initial()) {
    on<_StatusTable>((event, emit) async {
      emit(_Loading());
      await datasource.updateStatusTable(event.table);
      emit(_Success());
    });
  }
}
