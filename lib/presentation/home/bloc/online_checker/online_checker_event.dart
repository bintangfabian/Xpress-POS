part of 'online_checker_bloc.dart';

@freezed
class OnlineCheckerEvent with _$OnlineCheckerEvent {
  const factory OnlineCheckerEvent.started() = _Started;
  const factory OnlineCheckerEvent.check(bool isOnline) = _Check;
}