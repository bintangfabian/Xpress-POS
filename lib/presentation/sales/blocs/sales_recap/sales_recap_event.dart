abstract class SalesRecapEvent {}

class GetSalesRecap extends SalesRecapEvent {
  final String startDate;
  final String endDate;
  GetSalesRecap({required this.startDate, required this.endDate});
}
