import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/product_local_datasource.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_table_status_event.dart';
part 'get_table_status_state.dart';
part 'get_table_status_bloc.freezed.dart';

class GetTableStatusBloc
    extends Bloc<GetTableStatusEvent, GetTableStatusState> {
  GetTableStatusBloc() : super(_Initial()) {
    on<_GetTablesStatus>((event, emit) async {
      emit(_Loading());
      final tables =
          await ProductLocalDatasource.instance.getTableByStatus(event.status);
      emit(_Success(tables));
    });
  }
}
