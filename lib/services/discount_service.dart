import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import '../../models/stand/discount.dart';
import '../../models/stand/create_discount.dart';
import '../../models/stand/update_discount.dart';

class DiscountService {
  final Dio _dio;

  ApiResponse<List<Discount>>? discountCache;
  DateTime? _discountCacheTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  DiscountService(this._dio);

  Future<ApiResponse<List<Discount>>> getDiscounts(
      {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        discountCache != null &&
        _discountCacheTime != null &&
        DateTime.now().difference(_discountCacheTime!) < _cacheDuration) {
      return discountCache!;
    }

    try {
      final response = await _dio.get('/discounts');
      final apiResponse = ApiResponse<List<Discount>>.fromJson(
        response.data,
        (json) => (json as List).map((e) => Discount.fromJson(e)).toList(),
      );

      discountCache = apiResponse;
      _discountCacheTime = DateTime.now();

      return apiResponse;
    } on DioError catch (e) {
      if (discountCache != null) {
        return discountCache!;
      }
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => [],
      );
    }
  }

  Future<ApiResponse<Discount>> getDiscountById(int id) async {
    try {
      final response = await _dio.get('/discounts/$id');
      return ApiResponse.fromJson(
        response.data,
        (json) => Discount.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Discount.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Discount>> createDiscount(CreateDiscountDto dto) async {
    try {
      final response = await _dio.post('/discounts', data: dto.toJson());

      discountCache = null;
      _discountCacheTime = null;

      return ApiResponse.fromJson(
        response.data,
        (json) => Discount.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Discount.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Discount>> updateDiscount(
      int id, UpdateDiscountDto dto) async {
    try {
      final response = await _dio.patch('/discounts/$id', data: dto.toJson());

      discountCache = null;
      _discountCacheTime = null;

      return ApiResponse.fromJson(
        response.data,
        (json) => Discount.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Discount.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Discount>> deleteDiscount(int id) async {
    try {
      final response = await _dio.delete('/discounts/$id');

      discountCache = null;
      _discountCacheTime = null;

      return ApiResponse.fromJson(
        response.data,
        (json) => Discount.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Discount.fromJson(json),
      );
    }
  }

  void clearDiscountCache() {
    discountCache = null;
    _discountCacheTime = null;
  }
}
