import 'package:xpress/data/models/response/cash_session_response_model.dart';

abstract class CashSessionState {}

class CashSessionInitial extends CashSessionState {}

class CashSessionLoading extends CashSessionState {}

class CashSessionEmpty extends CashSessionState {}

class CashSessionSuccess extends CashSessionState {
  final CashSessionData data;
  CashSessionSuccess(this.data);
}

class CashSessionError extends CashSessionState {
  final String message;
  CashSessionError(this.message);
}
