abstract class SalesSummaryEvent {}

class GetSalesSummary extends SalesSummaryEvent {
  final String startDate;
  final String endDate;
  GetSalesSummary({required this.startDate, required this.endDate});
}
