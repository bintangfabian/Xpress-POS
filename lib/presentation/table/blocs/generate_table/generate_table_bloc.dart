import 'package:bloc/bloc.dart';
import 'package:xpress/data/datasources/table_remote_datasource.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_table_event.dart';
part 'generate_table_state.dart';
part 'generate_table_bloc.freezed.dart';

class GenerateTableBloc extends Bloc<GenerateTableEvent, GenerateTableState> {
  final TableRemoteDatasource remote;
  GenerateTableBloc(this.remote) : super(_Initial()) {
    on<_Generate>((event, emit) async {
      emit(_Loading());
      final result = await remote.addTables(event.count);
      result.fold(
        (err) => emit(_Success('ERROR: $err')),
        (_) => emit(_Success('Generate Success')),
      );
    });
  }
}
