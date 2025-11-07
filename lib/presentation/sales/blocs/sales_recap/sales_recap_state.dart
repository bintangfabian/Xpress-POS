import 'package:xpress/data/models/response/sales_recap_response_model.dart';

abstract class SalesRecapState {}

class SalesRecapInitial extends SalesRecapState {}

class SalesRecapLoading extends SalesRecapState {}

class SalesRecapSuccess extends SalesRecapState {
  final SalesRecapData data;
  SalesRecapSuccess(this.data);
}

class SalesRecapError extends SalesRecapState {
  final String message;
  SalesRecapError(this.message);
}
