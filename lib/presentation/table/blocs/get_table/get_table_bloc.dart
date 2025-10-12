import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/table_remote_datasource.dart';
import 'package:xpress/data/models/response/table_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_table_event.dart';
part 'get_table_state.dart';
part 'get_table_bloc.freezed.dart';

class GetTableBloc extends Bloc<GetTableEvent, GetTableState> {
  final TableRemoteDatasource remote;
  GetTableBloc(this.remote) : super(_Initial()) {
    on<_GetTables>((event, emit) async {
      emit(_Loading());
      final result = await remote.getTables();
      result.fold(
        (err) => emit(const _Success([])),
        (tables) => emit(_Success(tables)),
      );
    });
  }
}
