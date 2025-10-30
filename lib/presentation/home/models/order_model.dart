// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:xpress/presentation/home/models/product_quantity.dart';

//  id INTEGER PRIMARY KEY AUTOINCREMENT,
//       sub_total INTEGER,
//       tax INTEGER,
//       discount INTEGER,
//       service_charge INTEGER,
//       total INTEGER,
//       payment_method TEXT,
//       total_item INTEGER,
//       id_kasir INTEGER,
//       nama_kasir TEXT,
//       transaction_time TEXT,
//       is_sync INTEGER DEFAULT 0

class OrderModel {
  final int? id;
  //payment_amount
  final int paymentAmount;
  final int subTotal;
  final int tax;
  final int discount;
  final int discountAmount;
  final int serviceCharge;
  final int total;
  final String paymentMethod;
  final int totalItem;
  final int idKasir;
  final String namaKasir;
  final String transactionTime;
  final String customerName;
  final int tableNumber;
  final String status;
  final String paymentStatus;
  final int isSync;
  final String operationMode;
  final List<ProductQuantity> orderItems;
  OrderModel({
    this.id,
    required this.paymentAmount,
    required this.subTotal,
    required this.tax,
    required this.discount,
    required this.discountAmount,
    required this.serviceCharge,
    required this.total,
    required this.paymentMethod,
    required this.totalItem,
    required this.idKasir,
    required this.namaKasir,
    required this.transactionTime,
    required this.customerName,
    required this.tableNumber,
    required this.status,
    required this.paymentStatus,
    required this.isSync,
    required this.operationMode,
    required this.orderItems,
  });

  //  'payment_amount' => 'required',
  //           'sub_total' => 'required',
  //           'tax' => 'required',
  //           'discount' => 'required',
  //           'service_charge' => 'required',
  //           'total' => 'required',
  //           'payment_method' => 'required',
  //           'total_item' => 'required',
  //           'id_kasir' => 'required',
  //           'nama_kasir' => 'required',
  //           'transaction_time' => 'required',
  //           'order_items' => 'required'

  Map<String, dynamic> toServerMap() {
    return {
      'payment_amount': paymentAmount,
      'sub_total': subTotal,
      'tax': tax,
      'discount': discount,
      'discount_amount': discountAmount,
      'service_charge': serviceCharge,
      'total': total,
      'payment_method': paymentMethod,
      'total_item': totalItem,
      'id_kasir': idKasir,
      'nama_kasir': namaKasir,
      'customer_name': customerName,
      'table_number': tableNumber,
      'status': status,
      'payment_status': paymentStatus,
      'transaction_time': transactionTime,
      'operation_mode': normalizeOperationMode(operationMode),
      'order_items': orderItems.map((e) => e.toServerMap(id)).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'payment_amount': paymentAmount,
      'sub_total': subTotal,
      'tax': tax,
      'discount': discount,
      'discount_amount': discountAmount,
      'service_charge': serviceCharge,
      'total': total,
      'payment_method': paymentMethod,
      'total_item': totalItem,
      'id_kasir': 1,
      'nama_kasir': 'Kasir',
      'transaction_time': transactionTime,
      'customer_name': customerName,
      'table_number': tableNumber,
      'status': status,
      'payment_status': paymentStatus,
      'is_sync': isSync,
      'operation_mode': normalizeOperationMode(operationMode),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toInt(),
      paymentAmount: map['payment_amount']?.toInt() ?? 0,
      subTotal: map['sub_total']?.toInt() ?? 0,
      tax: map['tax']?.toInt() ?? 0,
      discount: map['discount']?.toInt() ?? 0,
      discountAmount: map['discount_amount']?.toInt() ?? 0,
      serviceCharge: map['service_charge']?.toInt() ?? 0,
      total: map['total']?.toInt() ?? 0,
      paymentMethod: map['payment_method'] ?? '',
      totalItem: map['total_item']?.toInt() ?? 0,
      idKasir: map['id_kasir']?.toInt() ?? 0,
      namaKasir: map['nama_kasir'] ?? '',
      transactionTime: map['transaction_time'] ?? '',
      isSync: map['is_sync']?.toInt() ?? 0,
      customerName: map['customer_name'] ?? '',
      tableNumber: map['table_number']?.toInt() ?? 0,
      status: map['status'] ?? '',
      paymentStatus: map['payment_status'] ?? '',
      orderItems: [],
      operationMode: normalizeOperationMode(
          map['operation_mode'] ?? map['order_type'] ?? map['operationMode']),
    );
  }

  String toJson() => json.encode(toServerMap());

  factory OrderModel.fromJson(String source) =>
      OrderModel.fromMap(json.decode(source));

  OrderModel copyWith({
    int? id,
    int? paymentAmount,
    int? subTotal,
    int? tax,
    int? discount,
    int? discountAmount,
    int? serviceCharge,
    int? total,
    String? paymentMethod,
    int? totalItem,
    int? idKasir,
    String? namaKasir,
    String? transactionTime,
    String? customerName,
    int? tableNumber,
    String? status,
    String? paymentStatus,
    int? isSync,
    String? operationMode,
    List<ProductQuantity>? orderItems,
  }) {
    return OrderModel(
      id: id ?? this.id,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      subTotal: subTotal ?? this.subTotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      discountAmount: discountAmount ?? this.discountAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalItem: totalItem ?? this.totalItem,
      idKasir: idKasir ?? this.idKasir,
      namaKasir: namaKasir ?? this.namaKasir,
      transactionTime: transactionTime ?? this.transactionTime,
      customerName: customerName ?? this.customerName,
      tableNumber: tableNumber ?? this.tableNumber,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      isSync: isSync ?? this.isSync,
      operationMode: operationMode ?? this.operationMode,
      orderItems: orderItems ?? this.orderItems,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, paymentAmount: $paymentAmount, subTotal: $subTotal, tax: $tax, discount: $discount, discountAmount: $discountAmount, serviceCharge: $serviceCharge, total: $total, paymentMethod: $paymentMethod, totalItem: $totalItem, idKasir: $idKasir, namaKasir: $namaKasir, transactionTime: $transactionTime, customerName: $customerName, tableNumber: $tableNumber, status: $status, paymentStatus: $paymentStatus, isSync: $isSync, operationMode: $operationMode, orderItems: $orderItems)';
  }
}

String normalizeOperationMode(dynamic mode) {
  final value = (mode ?? '').toString().trim().toLowerCase();
  final sanitized = value.replaceAll(RegExp(r'[\s_-]'), '');
  switch (sanitized) {
    case 'dinein':
      return 'dine_in';
    case 'takeaway':
    case 'takeout':
      return 'takeaway';
    default:
      return 'dine_in';
  }
}

String operationModeLabel(String? mode) {
  final value = (mode ?? '').toString().trim().toLowerCase();
  final sanitized = value.replaceAll(RegExp(r'[\s_-]'), '');
  switch (sanitized) {
    case 'dinein':
      return 'Dine In';
    case 'takeaway':
    case 'takeout':
      return 'Take Away';
    default:
      return '-';
  }
}
