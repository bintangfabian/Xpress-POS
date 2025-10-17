import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/repositories/sync_repository.dart';
import '../../../presentation/home/bloc/online_checker/online_checker_bloc.dart';

part 'sync_bloc.freezed.dart';
part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required SyncRepository syncRepository,
    required OnlineCheckerBloc onlineCheckerBloc,
  })  : _syncRepository = syncRepository,
        _onlineCheckerBloc = onlineCheckerBloc,
        super(const SyncState.initial()) {
    on<_SyncRequested>(_onSyncRequested);
  }

  final SyncRepository _syncRepository;
  final OnlineCheckerBloc _onlineCheckerBloc;

  Future<void> _onSyncRequested(
    _SyncRequested event,
    Emitter<SyncState> emit,
  ) async {
    if (!_onlineCheckerBloc.isOnline) {
      emit(const SyncState.failure('Perangkat sedang offline.'));
      return;
    }

    emit(const SyncState.inProgress());
    try {
      await _syncRepository.runFullSync();
      emit(const SyncState.success());
    } on SyncException catch (error) {
      emit(SyncState.failure(error.message));
    } catch (error) {
      emit(SyncState.failure(error.toString()));
    }
  }
}
