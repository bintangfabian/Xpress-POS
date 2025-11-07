abstract class CashSessionEvent {}

class GetCurrentCashSession extends CashSessionEvent {}

class OpenCashSession extends CashSessionEvent {
  final int openingBalance;
  OpenCashSession(this.openingBalance);
}

class CloseCashSession extends CashSessionEvent {
  final String sessionId;
  final int closingBalance;
  CloseCashSession(this.sessionId, this.closingBalance);
}

class AddCashExpense extends CashSessionEvent {
  final String sessionId;
  final int amount;
  final String description;
  final String? category;
  AddCashExpense({
    required this.sessionId,
    required this.amount,
    required this.description,
    this.category,
  });
}
