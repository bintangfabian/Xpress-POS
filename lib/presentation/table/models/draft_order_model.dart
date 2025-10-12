import 'dart:convert';
import 'dart:developer';

import 'package:xpress/presentation/table/models/draft_order_item.dart';

import '../../home/models/order_item.dart';

class DraftOrderModel {
  final int? id;
  final List<DraftOrderItem> orders;

  final int totalQuantity;
  final int subTotal;
  final int tax;
  final int discount;
  final int discountAmount;
  final int serviceCharge;
  final int totalPrice;
  final String transactionTime;
  final int tableNumber;
  final String draftName;

  DraftOrderModel({
    this.id,
    required this.orders,
    required this.totalQuantity,
    required this.subTotal,
    required this.tax,
    required this.discount,
    required this.discountAmount,
    required this.serviceCharge,
    required this.totalPrice,
    required this.tableNumber,
    required this.draftName,
    required this.transactionTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'orders': orders.map((x) => x.toMap()).toList(),
      'totalQuantity': totalQuantity,
      'totalPrice': totalPrice,
      'tableNumber': tableNumber,
      'draftName': draftName,
    };
  }

  //  mominal INTEGER,
  //       payment_method TEXT
  //       total_item INTEGER,
  //       id_kasir INTEGER,
  //       nama_kasir TEXT,
  //       is_sync INTEGER DEFAULT 0

  Map<String, dynamic> toMapForLocal() {
    return {
      'total_item': totalQuantity,
      'subTotal': subTotal,
      'tax': tax,
      'discount': discount,
      'discount_amount': discountAmount,
      'service_charge': serviceCharge,
      'total': totalPrice,
      'table_number': tableNumber,
      'transaction_time': transactionTime,
      'draft_name': draftName,
    };
  }

  factory DraftOrderModel.fromLocalMap(Map<String, dynamic> map) {
    return DraftOrderModel(
      orders: [],
      totalQuantity: map['total_item']?.toInt() ?? 0,
      totalPrice: map['nominal']?.toInt() ?? 0,
      id: map['id']?.toInt() ?? 0,
      transactionTime: map['transaction_time'] ?? '',
      tableNumber: map['table_number']?.toInt() ?? 0,
      draftName: map['draft_name'] ?? '',
      discount: map['discount']?.toInt() ?? 0,
      discountAmount: map['discount_amount']?.toInt() ?? 0,
      serviceCharge: map['service_charge']?.toInt() ?? 0,
      subTotal: map['subTotal']?.toInt() ?? 0,
      tax: map['tax']?.toInt() ?? 0,
    );
  }

  factory DraftOrderModel.newFromLocalMap(
      Map<String, dynamic> map, List<DraftOrderItem> orders) {
    log("newFromLocalMap: $map");
    return DraftOrderModel(
      orders: orders,
      totalQuantity: map['total_item']?.toInt() ?? 0,
      totalPrice: map['nominal']?.toInt() ?? 0,
      id: map['id']?.toInt() ?? 0,
      transactionTime: map['transaction_time'] ?? '',
      tableNumber: map['table_number']?.toInt() ?? 0,
      draftName: map['draft_name'] ?? '',
      discount: map['discount']?.toInt() ?? 0,
      discountAmount: map['discount_amount']?.toInt() ?? 0,
      serviceCharge: map['service_charge']?.toInt() ?? 0,
      subTotal: map['subTotal']?.toInt() ?? 0,
      tax: map['tax']?.toInt() ?? 0,
    );
  }

  factory DraftOrderModel.fromMap(Map<String, dynamic> map) {
    return DraftOrderModel(
      orders: List<DraftOrderItem>.from(
          map['orders']?.map((x) => OrderItem.fromMap(x))),
      totalQuantity: map['totalQuantity']?.toInt() ?? 0,
      totalPrice: map['totalPrice']?.toInt() ?? 0,
      id: map['id']?.toInt() ?? 0,
      transactionTime: map['transactionTime'] ?? '',
      tableNumber: map['tableNumber']?.toInt() ?? 0,
      draftName: map['draftName'] ?? '',
      discount: map['discount']?.toInt() ?? 0,
      discountAmount: map['discountAmount']?.toInt() ?? 0,
      serviceCharge: map['serviceCharge']?.toInt() ?? 0,
      subTotal: map['subTotal']?.toInt() ?? 0,
      tax: map['tax']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory DraftOrderModel.fromJson(String source) =>
      DraftOrderModel.fromMap(json.decode(source));
}
