import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/datasources/auth_local_datasource.dart';
import '../../../../data/datasources/auth_remote_datasource.dart';
import '../../../home/bloc/online_checker/online_checker_bloc.dart';

part 'logout_bloc.freezed.dart';
part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutBloc({
    required AuthRemoteDatasource authRemoteDatasource,
    required AuthLocalDataSource authLocalDataSource,
    required OnlineCheckerBloc onlineCheckerBloc,
  })  : _authRemoteDatasource = authRemoteDatasource,
        _authLocalDataSource = authLocalDataSource,
        _onlineCheckerBloc = onlineCheckerBloc,
        super(const _Initial()) {
    on<_Logout>(_onLogout);
  }

  final AuthRemoteDatasource _authRemoteDatasource;
  final AuthLocalDataSource _authLocalDataSource;
  final OnlineCheckerBloc _onlineCheckerBloc;

  Future<void> _onLogout(
    _Logout event,
    Emitter<LogoutState> emit,
  ) async {
    emit(const _Loading());
    String? errorMessage;

    if (_onlineCheckerBloc.isOnline) {
      final result = await _authRemoteDatasource.logout();
      result.fold(
        (error) => errorMessage = error,
        (_) {},
      );
    }

    await _authLocalDataSource.removeAuthData();

    if (errorMessage != null) {
      emit(_Error(errorMessage!));
    }
    emit(const _Success());
  }
}
