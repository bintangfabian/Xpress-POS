// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CategroyResponseModel {
  final List<CategoryModel> data;

  CategroyResponseModel({
    required this.data,
  });

  factory CategroyResponseModel.fromJson(String str) {
    final map = json.decode(str);
    List list = [];
    if (map is Map && map['data'] is List) {
      list = map['data'];
    } else if (map is List) {
      list = map;
    }
    return CategroyResponseModel(
      data: list
          .map<CategoryModel>((x) => CategoryModel.fromMap(
              x is Map<String, dynamic> ? x : <String, dynamic>{}))
          .toList(),
    );
  }
}

class CategoryModel {
  int? id;
  String? name;
  String? image;

  CategoryModel({this.id, this.name, this.image});

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}'),
      name: map['name']?.toString(),
      image: map['image']?.toString(),
    );
  }
}
