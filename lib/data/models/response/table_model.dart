// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:xpress/core/utils/timezone_helper.dart';

class TableModel {
  String? id; // Changed to String to support UUID
  final String? tableNumber; // Changed to String to support T001 format
  final String? name; // Added name field
  final int? capacity; // Added capacity field
  final int? isActive; // Added is_active field
  final String? storeId; // Added store_id field
  final String startTime;
  final String status;
  final int orderId;
  final int paymentAmount;

  TableModel({
    this.id,
    this.tableNumber,
    this.name,
    this.capacity,
    this.isActive,
    this.storeId,
    required this.startTime,
    required this.status,
    required this.orderId,
    required this.paymentAmount,
  });

  // from map
  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id']?.toString(), // Convert to string to support UUID
      tableNumber: map['table_number']?.toString(),
      name: map['name']?.toString(),
      capacity: map['capacity'] is int
          ? map['capacity']
          : int.tryParse(map['capacity']?.toString() ?? '0'),
      isActive: map['is_active'] is int
          ? map['is_active']
          : int.tryParse(map['is_active']?.toString() ?? '1'),
      storeId: map['store_id']?.toString(),
      startTime: map['start_time'] ?? TimezoneHelper.now().toIso8601String(),
      status: map['status'] ?? 'available',
      orderId: map['order_id'] is int
          ? map['order_id']
          : int.tryParse(map['order_id']?.toString() ?? '0') ?? 0,
      paymentAmount: map['payment_amount'] is int
          ? map['payment_amount']
          : int.tryParse(map['payment_amount']?.toString() ?? '0') ?? 0,
    );
  }

  // to map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (tableNumber != null) 'table_number': tableNumber,
      if (name != null) 'name': name,
      if (capacity != null) 'capacity': capacity,
      if (isActive != null) 'is_active': isActive,
      if (storeId != null) 'store_id': storeId,
      'status': status,
      'start_time': startTime,
      'order_id': orderId,
      'payment_amount': paymentAmount,
    };
  }
}
