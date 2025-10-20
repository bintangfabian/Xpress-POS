import 'package:bloc/bloc.dart';
import 'package:xpress/data/datasources/discount_remote_datasource.dart';

part 'delete_discount_state.dart';

class DeleteDiscountCubit extends Cubit<DeleteDiscountState> {
  final DiscountRemoteDatasource _datasource;

  DeleteDiscountCubit(this._datasource)
      : super(DeleteDiscountState.initial());

  Future<void> delete(int id) async {
    emit(DeleteDiscountState.loading());
    final result = await _datasource.deleteDiscount(id);
    result.fold(
      (message) => emit(DeleteDiscountState.error(message)),
      (_) => emit(DeleteDiscountState.success()),
    );
  }
}
