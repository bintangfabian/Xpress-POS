import 'dart:convert';
import 'dart:developer' as developer;

void _orderResponseLog(String message) {
  assert(() {
    const bool enableOrderResponseVerboseLog = false;
    if (enableOrderResponseVerboseLog) {
      developer.log(message, name: 'OrderResponseModel');
    }
    return true;
  }());
}

class OrderResponseModel {
  String? status;
  List<ItemOrder>? data;
  OrderResponseMeta? meta;

  OrderResponseModel({
    this.status,
    this.data,
    this.meta,
  });

  factory OrderResponseModel.fromJson(String str) =>
      OrderResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OrderResponseModel.fromMap(Map<String, dynamic> json) {
    _orderResponseLog('=== PARSING ORDER RESPONSE ===');
    _orderResponseLog('JSON keys: ${json.keys.toList()}');
    _orderResponseLog(
        'success: ${json["success"]} (type: ${json["success"].runtimeType})');
    _orderResponseLog(
        'status: ${json["status"]} (type: ${json["status"].runtimeType})');
    _orderResponseLog(
        'data: ${json["data"]} (type: ${json["data"].runtimeType})');
    _orderResponseLog('data length: ${json["data"]?.length}');
    if (json["data"] != null &&
        json["data"] is List &&
        json["data"].isNotEmpty) {
      _orderResponseLog('First data item: ${json["data"][0]}');
      _orderResponseLog(
          'First data item keys: ${json["data"][0].keys.toList()}');
    }
    _orderResponseLog('=============================');

    return OrderResponseModel(
      status: json["status"] ?? (json["success"] == true ? "success" : "error"),
      data: json["data"] == null
          ? []
          : List<ItemOrder>.from(
              json["data"]!.map((x) => ItemOrder.fromMap(x))),
      meta: json["meta"] == null ? null : OrderResponseMeta.fromMap(json["meta"]),
    );
  }

  Map<String, dynamic> toMap() => {
        "status": status,
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
        "meta": meta?.toMap(),
      };
}

class OrderResponseMeta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;
  bool? hasMore;
  Map<String, dynamic>? dateWindow;
  String? timestamp;
  String? version;

  OrderResponseMeta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
    this.hasMore,
    this.dateWindow,
    this.timestamp,
    this.version,
  });

  factory OrderResponseMeta.fromMap(Map<String, dynamic> json) {
    int? current = json["current_page"];
    int? last = json["last_page"];
    bool? hasMoreFlag = json["has_more"];
    hasMoreFlag ??= (current != null && last != null) ? current < last : null;

    return OrderResponseMeta(
      currentPage: current,
      lastPage: last,
      perPage: json["per_page"],
      total: json["total"],
      hasMore: hasMoreFlag,
      dateWindow: json["date_window"] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json["date_window"])
          : null,
      timestamp: json["timestamp"]?.toString(),
      version: json["version"]?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        "current_page": currentPage,
        "last_page": lastPage,
        "per_page": perPage,
        "total": total,
        "has_more": hasMore,
        "date_window": dateWindow,
        "timestamp": timestamp,
        "version": version,
      };
}

class ItemOrder {
  String? id;
  String? orderNumber;
  String? status;
  String? subtotal;
  String? taxAmount;
  String? discountAmount;
  String? serviceCharge;
  String? totalAmount;
  int? totalItems;
  String? paymentMethod;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? completedAt;
  User? user;
  Member? member;
  Table? table;
  List<OrderItem>? items;
  List<Payment>? payments;
  List<Refund>? refunds;
  bool? canBeModified;
  bool? isCompleted;
  bool? isPaid;
  String? operationMode;

  ItemOrder({
    this.id,
    this.orderNumber,
    this.status,
    this.subtotal,
    this.taxAmount,
    this.discountAmount,
    this.serviceCharge,
    this.totalAmount,
    this.totalItems,
    this.paymentMethod,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.user,
    this.member,
    this.table,
    this.items,
    this.payments,
    this.refunds,
    this.canBeModified,
    this.isCompleted,
    this.isPaid,
    this.operationMode,
  });

  factory ItemOrder.fromJson(String str) => ItemOrder.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ItemOrder.fromMap(Map<String, dynamic> json) {
    _orderResponseLog('=== PARSING ORDER ===');
    _orderResponseLog('JSON keys: ${json.keys.toList()}');
    _orderResponseLog('id: ${json["id"]} (type: ${json["id"].runtimeType})');
    _orderResponseLog('id is null: ${json["id"] == null}');
    _orderResponseLog('id is empty: ${json["id"]?.toString().isEmpty ?? true}');
    _orderResponseLog('id length: ${json["id"]?.toString().length}');
    _orderResponseLog(
        'order_number: ${json["order_number"]} (type: ${json["order_number"].runtimeType})');
    _orderResponseLog(
        'total_amount: ${json["total_amount"]} (type: ${json["total_amount"].runtimeType})');
    _orderResponseLog(
        'subtotal: ${json["subtotal"]} (type: ${json["subtotal"].runtimeType})');
    _orderResponseLog('user: ${json["user"]}');
    _orderResponseLog('table: ${json["table"]}');
    _orderResponseLog('items: ${json["items"]}');
    _orderResponseLog('====================');

    return ItemOrder(
      id: json["id"]?.toString(),
      orderNumber: json["order_number"]?.toString(),
      status: json["status"]?.toString(),
      subtotal: json["subtotal"]?.toString(),
      taxAmount: json["tax_amount"]?.toString(),
      discountAmount: json["discount_amount"]?.toString(),
      serviceCharge: json["service_charge"]?.toString(),
      totalAmount: json["total_amount"]?.toString(),
      totalItems: json["total_items"],
      paymentMethod: json["payment_method"]?.toString(),
      notes: json["notes"]?.toString(),
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json["updated_at"] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      completedAt: json["completed_at"] == null
          ? null
          : DateTime.parse(json["completed_at"]),
      user: json["user"] == null ? null : User.fromMap(json["user"]),
      member: json["member"] == null ? null : Member.fromMap(json["member"]),
      table: json["table"] == null ? null : Table.fromMap(json["table"]),
      items: json["items"] == null
          ? null
          : List<OrderItem>.from(
              json["items"].map((x) => OrderItem.fromMap(x))),
      payments: json["payments"] == null
          ? null
          : List<Payment>.from(json["payments"].map((x) => Payment.fromMap(x))),
      refunds: json["refunds"] == null
          ? null
          : List<Refund>.from(json["refunds"].map((x) => Refund.fromMap(x))),
      canBeModified: json["can_be_modified"],
      isCompleted: json["is_completed"],
      isPaid: json["is_paid"],
      operationMode: _extractOperationMode(json),
    );
  }

  Map<String, dynamic> toMap() => {
        "id": id,
        "order_number": orderNumber,
        "status": status,
        "subtotal": subtotal,
        "tax_amount": taxAmount,
        "discount_amount": discountAmount,
        "service_charge": serviceCharge,
        "total_amount": totalAmount,
        "total_items": totalItems,
        "payment_method": paymentMethod,
        "notes": notes,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "completed_at": completedAt?.toIso8601String(),
        "user": user?.toMap(),
        "member": member?.toMap(),
        "table": table?.toMap(),
        "items": items == null
            ? null
            : List<dynamic>.from(items!.map((x) => x.toMap())),
        "payments": payments == null
            ? null
            : List<dynamic>.from(payments!.map((x) => x.toMap())),
        "refunds": refunds == null
            ? null
            : List<dynamic>.from(refunds!.map((x) => x.toMap())),
        "can_be_modified": canBeModified,
        "is_completed": isCompleted,
        "is_paid": isPaid,
        "operation_mode": operationMode,
      };
}

String? _extractOperationMode(Map<String, dynamic> json) {
  dynamic value;
  final candidates = [
    json['operation_mode'],
    json['operationMode'],
    json['order_type'],
    json['orderType'],
    if (json['metadata'] is Map<String, dynamic>)
      (json['metadata'] as Map<String, dynamic>)['operation_mode'],
    if (json['metadata'] is Map<String, dynamic>)
      (json['metadata'] as Map<String, dynamic>)['order_type'],
  ];
  for (final candidate in candidates) {
    if (candidate == null) continue;
    final text = candidate.toString().trim();
    if (text.isEmpty) continue;
    value = text;
    break;
  }
  return value;
}

class User {
  int? id;
  String? name;

  User({this.id, this.name});

  factory User.fromMap(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"]?.toString(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };
}

class Member {
  String? id;
  String? name;

  Member({this.id, this.name});

  factory Member.fromMap(Map<String, dynamic> json) => Member(
        id: json["id"]?.toString(),
        name: json["name"]?.toString(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };
}

class Table {
  String? id;
  String? tableNumber;
  String? name;
  int? capacity;
  String? status;
  String? statusDisplay;
  String? location;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? occupiedAt;
  DateTime? lastClearedAt;
  int? totalOccupancyCount;
  String? averageOccupancyDuration;
  String? notes;
  bool? isAvailable;
  bool? isOccupied;
  bool? canBeOccupied;
  int? currentOccupancyDuration;
  bool? isOccupiedTooLong;
  String? formattedAverageDuration;

  Table({
    this.id,
    this.tableNumber,
    this.name,
    this.capacity,
    this.status,
    this.statusDisplay,
    this.location,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.occupiedAt,
    this.lastClearedAt,
    this.totalOccupancyCount,
    this.averageOccupancyDuration,
    this.notes,
    this.isAvailable,
    this.isOccupied,
    this.canBeOccupied,
    this.currentOccupancyDuration,
    this.isOccupiedTooLong,
    this.formattedAverageDuration,
  });

  factory Table.fromMap(Map<String, dynamic> json) => Table(
        id: json["id"]?.toString(),
        tableNumber: json["table_number"]?.toString(),
        name: json["name"]?.toString(),
        capacity: json["capacity"],
        status: json["status"]?.toString(),
        statusDisplay: json["status_display"]?.toString(),
        location: json["location"]?.toString(),
        isActive: json["is_active"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        occupiedAt: json["occupied_at"] == null
            ? null
            : DateTime.parse(json["occupied_at"]),
        lastClearedAt: json["last_cleared_at"] == null
            ? null
            : DateTime.parse(json["last_cleared_at"]),
        totalOccupancyCount: json["total_occupancy_count"],
        averageOccupancyDuration:
            json["average_occupancy_duration"]?.toString(),
        notes: json["notes"]?.toString(),
        isAvailable: json["is_available"],
        isOccupied: json["is_occupied"],
        canBeOccupied: json["can_be_occupied"],
        currentOccupancyDuration: json["current_occupancy_duration"],
        isOccupiedTooLong: json["is_occupied_too_long"],
        formattedAverageDuration:
            json["formatted_average_duration"]?.toString(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "table_number": tableNumber,
        "name": name,
        "capacity": capacity,
        "status": status,
        "status_display": statusDisplay,
        "location": location,
        "is_active": isActive,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "occupied_at": occupiedAt?.toIso8601String(),
        "last_cleared_at": lastClearedAt?.toIso8601String(),
        "total_occupancy_count": totalOccupancyCount,
        "average_occupancy_duration": averageOccupancyDuration,
        "notes": notes,
        "is_available": isAvailable,
        "is_occupied": isOccupied,
        "can_be_occupied": canBeOccupied,
        "current_occupancy_duration": currentOccupancyDuration,
        "is_occupied_too_long": isOccupiedTooLong,
        "formatted_average_duration": formattedAverageDuration,
      };
}

class OrderItem {
  String? id;
  int? productId;
  String? productName;
  String? productSku;
  int? quantity;
  String? unitPrice;
  String? totalPrice;
  List<dynamic>? productOptions;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;
  Product? product;
  int? lineTotal;

  OrderItem({
    this.id,
    this.productId,
    this.productName,
    this.productSku,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
    this.productOptions,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.product,
    this.lineTotal,
  });

  factory OrderItem.fromMap(Map<String, dynamic> json) => OrderItem(
        id: json["id"]?.toString(),
        productId: json["product_id"],
        productName: json["product_name"]?.toString(),
        productSku: json["product_sku"]?.toString(),
        quantity: json["quantity"],
        unitPrice: json["unit_price"]?.toString(),
        totalPrice: json["total_price"]?.toString(),
        productOptions: json["product_options"] == null
            ? null
            : List<dynamic>.from(json["product_options"]),
        notes: json["notes"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        product:
            json["product"] == null ? null : Product.fromMap(json["product"]),
        lineTotal: json["line_total"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "product_id": productId,
        "product_name": productName,
        "product_sku": productSku,
        "quantity": quantity,
        "unit_price": unitPrice,
        "total_price": totalPrice,
        "product_options": productOptions,
        "notes": notes,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "product": product?.toMap(),
        "line_total": lineTotal,
      };
}

class Product {
  int? id;
  String? name;
  String? sku;
  String? image;
  bool? trackInventory;
  int? stock;

  Product({
    this.id,
    this.name,
    this.sku,
    this.image,
    this.trackInventory,
    this.stock,
  });

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        name: json["name"]?.toString(),
        sku: json["sku"]?.toString(),
        image: json["image"]?.toString(),
        trackInventory: json["track_inventory"],
        stock: json["stock"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "sku": sku,
        "image": image,
        "track_inventory": trackInventory,
        "stock": stock,
      };
}

class Payment {
  String? id;
  String? amount;
  String? paymentMethod;
  String? status;
  String? referenceNumber;
  DateTime? processedAt;
  DateTime? createdAt;

  Payment({
    this.id,
    this.amount,
    this.paymentMethod,
    this.status,
    this.referenceNumber,
    this.processedAt,
    this.createdAt,
  });

  factory Payment.fromMap(Map<String, dynamic> json) => Payment(
        id: json["id"]?.toString(),
        amount: json["amount"]?.toString(),
        paymentMethod: (json["payment_method"] ?? json["method"])?.toString(),
        status: json["status"]?.toString(),
        referenceNumber: json["reference_number"]?.toString(),
        processedAt: json["processed_at"] == null
            ? null
            : DateTime.parse(json["processed_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "amount": amount,
        "payment_method": paymentMethod,
        "status": status,
        "reference_number": referenceNumber,
        "processed_at": processedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
      };
}

class Refund {
  String? id;
  String? amount;
  String? reason;
  DateTime? createdAt;

  Refund({this.id, this.amount, this.reason, this.createdAt});

  factory Refund.fromMap(Map<String, dynamic> json) => Refund(
        id: json["id"]?.toString(),
        amount: json["amount"]?.toString(),
        reason: json["reason"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "amount": amount,
        "reason": reason,
        "created_at": createdAt?.toIso8601String(),
      };
}
