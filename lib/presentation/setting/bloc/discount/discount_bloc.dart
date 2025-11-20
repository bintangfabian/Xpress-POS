import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/models/response/discount_response_model.dart';
import '../../../../data/repositories/discount_repository.dart';

part 'discount_bloc.freezed.dart';
part 'discount_event.dart';
part 'discount_state.dart';

class DiscountBloc extends Bloc<DiscountEvent, DiscountState> {
  final DiscountRepository repository;
  DiscountBloc(
    this.repository,
  ) : super(const _Initial()) {
    on<_GetDiscounts>((event, emit) async {
      emit(const _Loading());
      try {
        final discounts = await repository.getDiscounts();
        emit(_Loaded(discounts));
      } catch (e) {
        emit(_Error(e.toString()));
      }
    });
  }
}
