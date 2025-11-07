import 'package:xpress/data/models/response/best_sellers_response_model.dart';

abstract class BestSellersState {}

class BestSellersInitial extends BestSellersState {}

class BestSellersLoading extends BestSellersState {}

class BestSellersSuccess extends BestSellersState {
  final BestSellersData data;
  BestSellersSuccess(this.data);
}

class BestSellersError extends BestSellersState {
  final String message;
  BestSellersError(this.message);
}
