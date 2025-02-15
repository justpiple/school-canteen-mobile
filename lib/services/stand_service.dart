import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/menu.dart';
import '../models/stand/stand.dart';

class StandService {
  final Dio _dio;

  ApiResponse<List<Stand>>? _standsCache;
  DateTime? _standsCacheTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  final Map<int, ApiResponse<List<Menu>>> _menuCache = {};
  final Map<int, DateTime> _menuCacheTime = {};

  StandService(this._dio);

  Future<ApiResponse<List<Stand>>> getStands(
      {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _standsCache != null &&
        _standsCacheTime != null &&
        DateTime.now().difference(_standsCacheTime!) < _cacheDuration) {
      return _standsCache!;
    }

    try {
      final response = await _dio.get('/stands');
      final apiResponse = ApiResponse<List<Stand>>.fromJson(
        response.data,
        (json) => (json as List).map((stand) => Stand.fromJson(stand)).toList(),
      );

      _standsCache = apiResponse;
      _standsCacheTime = DateTime.now();

      return apiResponse;
    } on DioError catch (e) {
      if (_standsCache != null) {
        return _standsCache!;
      }

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

  Future<ApiResponse<List<Menu>>> getStandMenu(int standId,
      {bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _menuCache.containsKey(standId) &&
        _menuCacheTime.containsKey(standId) &&
        DateTime.now().difference(_menuCacheTime[standId]!) < _cacheDuration) {
      return _menuCache[standId]!;
    }

    try {
      final response = await _dio.get('/menu/stand/$standId');
      final apiResponse = ApiResponse<List<Menu>>.fromJson(
        response.data,
        (json) => (json as List).map((menu) => Menu.fromJson(menu)).toList(),
      );

      _menuCache[standId] = apiResponse;
      _menuCacheTime[standId] = DateTime.now();

      return apiResponse;
    } on DioError catch (e) {
      if (_menuCache.containsKey(standId)) {
        return _menuCache[standId]!;
      }

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
    _standsCache = null;
    _standsCacheTime = null;
    _menuCache.clear();
    _menuCacheTime.clear();
  }
}
