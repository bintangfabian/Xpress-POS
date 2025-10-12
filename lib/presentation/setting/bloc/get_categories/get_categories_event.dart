part of 'get_categories_bloc.dart';

@freezed
class GetCategoriesEvent with _$GetCategoriesEvent {
  const factory GetCategoriesEvent.started() = _Started;
  const factory GetCategoriesEvent.fetch() = _Fetch;
}
