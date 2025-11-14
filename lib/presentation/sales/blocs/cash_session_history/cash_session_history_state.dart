import 'package:xpress/data/models/response/cash_session_response_model.dart';

abstract class CashSessionHistoryState {}

class CashSessionHistoryInitial extends CashSessionHistoryState {}

class CashSessionHistoryLoading extends CashSessionHistoryState {}

class CashSessionsSuccess extends CashSessionHistoryState {
  final List<CashSessionData> sessions;
  CashSessionsSuccess(this.sessions);
}

class CashSessionDetailSuccess extends CashSessionHistoryState {
  final CashSessionData session;
  CashSessionDetailSuccess(this.session);
}

class CashSessionHistoryError extends CashSessionHistoryState {
  final String message;
  CashSessionHistoryError(this.message);
}
