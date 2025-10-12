import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryLocalDatasource {
  OrderHistoryLocalDatasource._();
  static final instance = OrderHistoryLocalDatasource._();

  static const _kLastOrderId = 'last_order_id';
  static const _kOrderHistory = 'order_history';

  Future<int> getCurrentOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getInt(_kLastOrderId) ?? 1);
  }

  Future<int> incrementOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kLastOrderId) ?? 1;
    final next = current + 1;
    await prefs.setInt(_kLastOrderId, next);
    return next;
  }

  Future<void> addHistory(Map<String, dynamic> record) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kOrderHistory);
    final List<dynamic> list = jsonStr != null ? json.decode(jsonStr) : [];
    list.add(record);
    await prefs.setString(_kOrderHistory, json.encode(list));
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_kOrderHistory);
    if (jsonStr == null) return [];
    final List<dynamic> list = json.decode(jsonStr);
    return list.cast<Map<String, dynamic>>();
  }
}

