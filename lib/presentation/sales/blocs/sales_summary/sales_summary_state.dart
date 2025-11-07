import 'package:xpress/data/models/response/sales_summary_response_model.dart';

abstract class SalesSummaryState {}

class SalesSummaryInitial extends SalesSummaryState {}

class SalesSummaryLoading extends SalesSummaryState {}

class SalesSummarySuccess extends SalesSummaryState {
  final SalesSummaryData data;
  SalesSummarySuccess(this.data);
}

class SalesSummaryError extends SalesSummaryState {
  final String message;
  SalesSummaryError(this.message);
}
