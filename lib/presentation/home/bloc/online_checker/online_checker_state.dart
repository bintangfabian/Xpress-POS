part of 'online_checker_bloc.dart';

@freezed
class OnlineCheckerState with _$OnlineCheckerState {
  const factory OnlineCheckerState.initial() = _Initial;
  const factory OnlineCheckerState.online() = _Online;
  const factory OnlineCheckerState.offline() = _Offline;
  const factory OnlineCheckerState.error(String message) = _Error;
}
