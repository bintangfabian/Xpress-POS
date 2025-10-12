import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'online_checker_event.dart';
part 'online_checker_state.dart';
part 'online_checker_bloc.freezed.dart';

class OnlineCheckerBloc extends Bloc<OnlineCheckerEvent, OnlineCheckerState> {
  OnlineCheckerBloc() : super(_Initial()) {
    on<_Check>((event, emit) {
      if (event.isOnline) {
        emit(const _Online());
      } else {
        emit(const _Offline());
      }
    });
  }
}
