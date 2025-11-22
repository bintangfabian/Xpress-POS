import 'package:xpress/data/datasources/category_local_datasource.dart';
import 'package:xpress/data/datasources/category_remote_datasource.dart';
import 'package:xpress/data/models/response/category_response_model.dart';

class CategoryRepository {
  CategoryRepository({
    required CategoryRemoteDatasource remoteDatasource,
    required CategoryLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final CategoryRemoteDatasource _remoteDatasource;
  final CategoryLocalDatasource _localDatasource;

  Future<List<CategoryModel>> getCategories() async {
    // Always try to sync from server first (even if offline checker says offline)
    // This ensures we get the latest data when possible
    try {
      final remoteResult = await _remoteDatasource.getCategories();
      await remoteResult.fold(
        (failure) async {
          // Log error but fall back to local cache
          print('CategoryRepository: Failed to fetch from remote: $failure');
        },
        (response) async {
          try {
            final categories = response.data;
            print(
                'CategoryRepository: Received ${categories.length} categories from server');
            if (categories.isNotEmpty) {
              // Clear old categories first to avoid duplicates
              await _localDatasource.clearAll();
              await _localDatasource.saveCategories(categories);
              print(
                  'CategoryRepository: Saved ${categories.length} categories to local database');
            } else {
              print(
                  'CategoryRepository: Warning - No categories received from server');
            }
          } catch (e) {
            print('CategoryRepository: Error saving categories to local: $e');
            print('CategoryRepository: Stack trace: ${StackTrace.current}');
          }
        },
      );
    } catch (e) {
      print('CategoryRepository: Exception while fetching categories: $e');
      print('CategoryRepository: Stack trace: ${StackTrace.current}');
    }

    // Always return from local
    final localCategories = await _localDatasource.getCategories();
    print(
        'CategoryRepository: Returning ${localCategories.length} categories from local database');
    if (localCategories.isEmpty) {
      print('CategoryRepository: WARNING - No categories in local database!');
    }
    return localCategories;
  }
}
