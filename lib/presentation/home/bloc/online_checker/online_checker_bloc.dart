import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'online_checker_event.dart';
part 'online_checker_state.dart';
part 'online_checker_bloc.freezed.dart';

class OnlineCheckerBloc extends Bloc<OnlineCheckerEvent, OnlineCheckerState> {
  OnlineCheckerBloc({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const OnlineCheckerState.initial()) {
    on<_Started>(_onStarted);
    on<_Check>(_onCheck);
    add(const OnlineCheckerEvent.started());
  }

  final Connectivity _connectivity;
  StreamSubscription<dynamic>? _subscription;

  bool get isOnline => state.maybeWhen(online: () => true, orElse: () => false);

  Future<void> _onStarted(
    _Started event,
    Emitter<OnlineCheckerState> emit,
  ) async {
    try {
      final initialResult = await _connectivity.checkConnectivity();
      final initialOnline = _mapConnectivityToOnline(initialResult);
      emit(
        initialOnline
            ? const OnlineCheckerState.online()
            : const OnlineCheckerState.offline(),
      );
    } catch (_) {
      emit(const OnlineCheckerState.offline());
    }

    await _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        add(OnlineCheckerEvent.check(_mapConnectivityToOnline(results)));
      },
      onError: (_) => add(const OnlineCheckerEvent.check(false)),
    );
  }

  void _onCheck(
    _Check event,
    Emitter<OnlineCheckerState> emit,
  ) {
    emit(
      event.isOnline
          ? const OnlineCheckerState.online()
          : const OnlineCheckerState.offline(),
    );
  }

  bool _mapConnectivityToOnline(dynamic result) {
    if (result is ConnectivityResult) {
      return result != ConnectivityResult.none;
    }
    if (result is List<ConnectivityResult>) {
      return result.any((element) => element != ConnectivityResult.none);
    }
    return false;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
