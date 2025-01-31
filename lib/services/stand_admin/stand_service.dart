import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import '../../models/stand/stand.dart';
import '../../models/stand/create_stand.dart';
import '../../models/stand/update_stand.dart';
import '../../models/stand/stand_stats.dart';

class StandService {
  final Dio _dio;

  ApiResponse<Stand>? standProfileCache;
  DateTime? _standProfileCacheTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  ApiResponse<StandStats>? _standStatsCache;
  DateTime? _standStatsCacheTime;

  StandService(this._dio);

  Future<ApiResponse<Stand>> getProfile({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        standProfileCache != null &&
        _standProfileCacheTime != null &&
        DateTime.now().difference(_standProfileCacheTime!) < _cacheDuration) {
      return standProfileCache!;
    }

    try {
      final response = await _dio.get('/stands/me');
      final apiResponse = ApiResponse<Stand>.fromJson(
        response.data,
        (json) => Stand.fromJson(json),
      );

      standProfileCache = apiResponse;
      _standProfileCacheTime = DateTime.now();

      return apiResponse;
    } on DioError catch (e) {
      if (standProfileCache != null) {
        return standProfileCache!;
      }

      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Stand.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Stand>> createProfile(CreateStandDto dto) async {
    try {
      final response = await _dio.post(
        '/stands',
        data: dto.toJson(),
      );

      standProfileCache = null;
      _standProfileCacheTime = null;

      return ApiResponse.fromJson(
        response.data,
        (json) => Stand.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Stand.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Stand>> updateProfile(UpdateStandDto dto) async {
    try {
      final response = await _dio.patch(
        '/stands/me',
        data: dto.toJson(),
      );

      standProfileCache = null;
      _standProfileCacheTime = null;

      return ApiResponse.fromJson(
        response.data,
        (json) => Stand.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Stand.fromJson(json),
      );
    }
  }

  Future<ApiResponse<StandStats>> getStats({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _standStatsCache != null &&
        _standStatsCacheTime != null &&
        DateTime.now().difference(_standStatsCacheTime!) < _cacheDuration) {
      return _standStatsCache!;
    }

    try {
      final response = await _dio.get('/stands/stats');
      final apiResponse = ApiResponse<StandStats>.fromJson(
        response.data,
        (json) => StandStats.fromJson(json),
      );

      _standStatsCache = apiResponse;
      _standStatsCacheTime = DateTime.now();

      return apiResponse;
    } on DioError catch (e) {
      if (_standStatsCache != null) {
        return _standStatsCache!;
      }

      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => StandStats.fromJson(json),
      );
    }
  }

  void clearStatsCache() {
    _standStatsCache = null;
    _standStatsCacheTime = null;
  }

  void clearProfileCache() {
    standProfileCache = null;
    _standProfileCacheTime = null;
  }
}
