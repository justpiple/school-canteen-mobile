class ApiResponse<T> {
  final String status;
  final String message;
  final int statusCode;
  final T? data;
  final dynamic error;

  ApiResponse({
    required this.status,
    required this.message,
    required this.statusCode,
    this.data,
    this.error,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      statusCode: json['statusCode'] ?? 500,
      data: json['data'] != null && fromJson != null
          ? fromJson(json['data'])
          : null,
      error: json['error'],
    );
  }

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}
