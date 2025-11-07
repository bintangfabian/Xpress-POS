abstract class BestSellersEvent {}

class GetBestSellers extends BestSellersEvent {
  final String startDate;
  final String endDate;
  final int limit;
  GetBestSellers({
    required this.startDate,
    required this.endDate,
    this.limit = 10,
  });
}
