import 'dart:convert';

import 'package:xpress/presentation/home/pages/confirm_payment_page.dart';

class ProductResponseModel {
  final String? status;
  final List<Product>? data;

  ProductResponseModel({
    this.status,
    this.data,
  });

  factory ProductResponseModel.fromJson(String str) =>
      ProductResponseModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductResponseModel.fromMap(Map<String, dynamic> json) {
    final root = json;
    final status = (root['status'] ?? root['message'] ?? (root['success'] == true ? 'success' : null)) as String?;

    dynamic node = root['data'];
    List<dynamic> rawList = const [];
    if (node is List) {
      rawList = node;
    } else if (node is Map<String, dynamic>) {
      if (node['data'] is List) {
        rawList = node['data'] as List;
      } else if (node['items'] is List) {
        rawList = node['items'] as List;
      } else if (node['results'] is List) {
        rawList = node['results'] as List;
      }
    }

    return ProductResponseModel(
      status: status,
      data: List<Product>.from(rawList.map((x) => Product.fromMap(x as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> toMap() => {
        "status": status,
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
      };
}

class Product {
  final int? id;
  final int? productId;
  final int? categoryId;
  final String? name;
  final String? description;
  final String? image;
  final String? price;
  final int? stock;
  final int? minStockLevel;
  final bool? trackInventory;
  final int? status;
  final int? isFavorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Category? category;

  Product({
    this.id,
    this.productId,
    this.categoryId,
    this.name,
    this.description,
    this.image,
    this.price,
    this.stock,
    this.minStockLevel,
    this.trackInventory,
    this.status,
    this.isFavorite,
    this.createdAt,
    this.updatedAt,
    this.category,
  });

  factory Product.fromJson(String str) => Product.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Product.fromMap(Map<String, dynamic> json) => Product(
        id: _asInt(json["id"]) ?? _asInt(json["product_id"]),
        productId: _asInt(json["product_id"]) ?? _asInt(json["id"]),
        categoryId: _extractCategoryId(json),
        name: (json["name"] ?? json["title"])?.toString(),
        description: (json["description"] ?? json["desc"] ?? "")?.toString(),
        image: (json["image"] ?? json["image_url"] ?? json["photo"])?.toString(),
        price: _extractPrice(json),
        stock: _asInt(json["stock"]) ?? _asInt(json["quantity"]) ?? 0,
        minStockLevel: _asInt(json['min_stock_level']) ?? 0,
        trackInventory: json['track_inventory'] is bool
            ? json['track_inventory'] as bool
            : (json['track_inventory']?.toString().toLowerCase() == 'true'),
        status: _asInt(json["status"]) ?? 1,
        isFavorite: _asInt(json["is_favorite"]) ?? 0,
        createdAt: _tryParseDate(json["created_at"]),
        updatedAt: _tryParseDate(json["updated_at"]),
        category: _extractCategory(json),
      );

  factory Product.fromOrderMap(Map<String, dynamic> json) => Product(
        id: json["id_product"],
        price: json["price"].toString(),
      );

  factory Product.fromLocalMap(Map<String, dynamic> json) => Product(
        id: json["id"],
        productId: json["product_id"],
        categoryId: json["categoryId"],
        category: Category(
          id: json["categoryId"],
          name: json["categoryName"],
        ),
        name: json["name"],
        description: json["description"],
        image: json["image"],
        price: json["price"],
        stock: json["stock"],
        status: json["status"],
        isFavorite: json["isFavorite"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toLocalMap() => {
        "product_id": id,
        "categoryId": categoryId,
        "categoryName": category?.name,
        "name": name,
        "description": description,
        "image": image,
        "price": price?.replaceAll(RegExp(r'\.0+$'), ''),
        "stock": stock,
        "status": status,
        "isFavorite": isFavorite,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };

  Map<String, dynamic> toMap() => {
        "id": id,
        "product_id": productId,
        "category_id": categoryId,
        "name": name,
        "description": description,
        "image": image,
        "price": price,
        "stock": stock,
        "status": status,
        "is_favorite": isFavorite,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "category": category?.toMap(),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.productId == productId &&
        other.categoryId == categoryId &&
        other.name == name &&
        other.description == description &&
        other.image == image &&
        other.price == price &&
        other.stock == stock &&
        other.status == status &&
        other.isFavorite == isFavorite &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productId.hashCode ^
        categoryId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        image.hashCode ^
        price.hashCode ^
        stock.hashCode ^
        status.hashCode ^
        isFavorite.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        category.hashCode;
  }
}

class Category {
  final int? id;
  final String? name;
  final String? description;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    this.id,
    this.name,
    this.description,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: _asInt(json["id"]) ?? _asInt(json["category_id"]),
        name: (json["name"] ?? json["title"] ?? json["category_name"])?.toString(),
        description: (json["description"] ?? json["desc"] ?? "")?.toString(),
        image: (json["image"] ?? json["image_url"])?.toString(),
        createdAt: _tryParseDate(json["created_at"]),
        updatedAt: _tryParseDate(json["updated_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  final s = v.toString();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

String _extractPrice(Map<String, dynamic> json) {
  final raw = json["price"] ?? json["price_string"] ?? json["price_cents"];
  if (raw == null) return '0';
  final s = raw.toString();
  if (s == 'null' || s.isEmpty) return '0';
  // Remove trailing .00 if present
  return s.replaceAll('.00', '');
}

int? _extractCategoryId(Map<String, dynamic> json) {
  // Prefer explicit ids
  final direct = _asInt(json['category_id']) ?? _asInt(json['categoryId']);
  if (direct != null) return direct;
  final cat = json['category'];
  if (cat is Map<String, dynamic>) {
    return _asInt(cat['id']) ?? _asInt(cat['category_id']);
  }
  return null;
}

Category? _extractCategory(Map<String, dynamic> json) {
  final cat = json['category'];
  if (cat == null) return null;
  if (cat is Map<String, dynamic>) return Category.fromMap(cat);
  if (cat is String) return Category(name: cat);
  return null;
}

DateTime? _tryParseDate(dynamic value) {
  if (value == null) return null;
  if (value is String && value.isEmpty) return null;
  try {
    return DateTime.parse(value.toString());
  } catch (_) {
    return null;
  }
}
