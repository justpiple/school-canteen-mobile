import 'package:dio/dio.dart';
import 'package:school_canteen/models/order.dart';
import 'dart:typed_data';
import '../models/api_response.dart';

class OrderService {
  final Dio _dio;
  ApiResponse<OrderList>? _cachedOrders;
  DateTime? _lastFetch;
  static const cacheDuration = Duration(minutes: 2);

  OrderService(this._dio);

  Future<ApiResponse<OrderList>> getOrders({
    Map<String, dynamic>? queryParams,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedOrders != null && _lastFetch != null) {
      final difference = DateTime.now().difference(_lastFetch!);
      if (difference < cacheDuration) {
        return _cachedOrders!;
      }
    }
    try {
      final response = await _dio.get('/orders', queryParameters: queryParams);
      final apiResponse = ApiResponse<OrderList>.fromJson(
        response.data,
        (json) => OrderList.fromJson(json),
      );

      _cachedOrders = apiResponse;
      _lastFetch = DateTime.now();

      return apiResponse;
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        {
          'status': 'error',
          'message': e.response?.data['message'] ?? 'An error occurred',
          'statusCode': e.response?.statusCode ?? 500,
        },
        null,
      );
    }
  }

  void clearCache() {
    _cachedOrders = null;
    _lastFetch = null;
  }

  Future<Uint8List> downloadReceipt(int orderId) async {
    try {
      final response = await _dio.get(
        '/orders/$orderId/receipt',
        options: Options(
            responseType: ResponseType.bytes,
            headers: {'Accept': 'application/pdf'}),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to download receipt: ${e.toString()}');
    }
  }

  Future<ApiResponse> createOrder(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        '/orders',
        data: payload,
      );
      return ApiResponse.fromJson(
        response.data,
        null,
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        {
          'status': 'error',
          'message': e.response?.data['message'] ?? 'An error occurred',
          'statusCode': e.response?.statusCode ?? 500,
        },
        null,
      );
    }
  }
}
