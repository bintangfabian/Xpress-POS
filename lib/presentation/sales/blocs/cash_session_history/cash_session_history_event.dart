abstract class CashSessionHistoryEvent {}

class GetCashSessions extends CashSessionHistoryEvent {
  final String? startDate;
  final String? endDate;
  GetCashSessions({this.startDate, this.endDate});
}

class GetCashSessionDetail extends CashSessionHistoryEvent {
  final String sessionId;
  GetCashSessionDetail({required this.sessionId});
}
