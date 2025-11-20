import 'package:bloc/bloc.dart';
import 'package:xpress/data/models/response/category_response_model.dart';
import 'package:xpress/data/repositories/category_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'get_categories_event.dart';
part 'get_categories_state.dart';
part 'get_categories_bloc.freezed.dart';

class GetCategoriesBloc extends Bloc<GetCategoriesEvent, GetCategoriesState> {
  final CategoryRepository repository;
  GetCategoriesBloc(
    this.repository,
  ) : super(const _Initial()) {
    on<_Fetch>((event, emit) async {
      emit(const _Loading());
      try {
        final categories = await repository.getCategories();
        emit(_Success(categories));
      } catch (e) {
        emit(_Error(e.toString()));
      }
    });
  }
}
