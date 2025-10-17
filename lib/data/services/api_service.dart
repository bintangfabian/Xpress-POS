class ApiResponse {
  const ApiResponse({
    required this.success,
    this.data,
    this.message,
  });

  final bool success;
  final dynamic data;
  final String? message;
}

class ApiService {
  Future<ApiResponse> syncUpload(Map<String, dynamic> payload) async {
    // TODO: Replace stub with POST /sync/upload call to Laravel backend.
    await Future.delayed(const Duration(milliseconds: 800));
    return const ApiResponse(success: true, data: {});
  }

  Future<ApiResponse> syncDownload(DateTime since) async {
    // TODO: Replace stub with GET /sync/download?since=<timestamp> call.
    await Future.delayed(const Duration(milliseconds: 800));
    return const ApiResponse(success: true, data: {});
  }
}
