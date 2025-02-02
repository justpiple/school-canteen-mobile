import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:dio/dio.dart';
import '../../models/api_response.dart';
import '../../models/menu.dart';
import '../../models/stand/create_menu.dart';
import '../../models/stand/update_menu.dart';

class MenuService {
  final Dio _dio;

  ApiResponse<List<Menu>>? menuCache;
  DateTime? _menuCacheTime;
  final Duration _cacheDuration = const Duration(minutes: 5);

  MenuService(this._dio);

  Future<ApiResponse<List<Menu>>> getMenus({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        menuCache != null &&
        _menuCacheTime != null &&
        DateTime.now().difference(_menuCacheTime!) < _cacheDuration) {
      return menuCache!;
    }

    try {
      final response = await _dio.get('/menu');
      final apiResponse = ApiResponse<List<Menu>>.fromJson(
        response.data,
        (json) => (json as List).map((e) => Menu.fromJson(e)).toList(),
      );

      menuCache = apiResponse;
      _menuCacheTime = DateTime.now();

      return apiResponse;
    } on DioError catch (e) {
      if (menuCache != null) {
        return menuCache!;
      }
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => [],
      );
    }
  }

  Future<ApiResponse<Menu>> getMenuById(int id) async {
    try {
      final response = await _dio.get('/menu/$id');
      return ApiResponse.fromJson(
        response.data,
        (json) => Menu.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Menu.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Menu>> createMenu(
      CreateMenuDto dto, File photoFile) async {
    try {
      final formData = FormData.fromMap(dto.toJson());
      MultipartFile file;

      if (kIsWeb) {
        Uint8List bytes = await photoFile.readAsBytes();
        file = MultipartFile.fromBytes(
          bytes,
          filename: photoFile.path.split('/').last,
        );
      } else {
        file = await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split('/').last,
        );
      }

      formData.files.add(MapEntry('photo', file));

      final response = await _dio.post('/menu', data: formData);

      menuCache = null;
      _menuCacheTime = null;

      return ApiResponse.fromJson(
        response.data,
        (json) => Menu.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Menu.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Menu>> updateMenu(int id, UpdateMenuDto dto,
      {File? photoFile}) async {
    try {
      final formData = FormData.fromMap(dto.toJson());

      if (photoFile != null) {
        MultipartFile file;

        if (kIsWeb) {
          Uint8List bytes = await photoFile.readAsBytes();
          file = MultipartFile.fromBytes(
            bytes,
            filename: photoFile.path.split('/').last,
          );
        } else {
          file = await MultipartFile.fromFile(
            photoFile.path,
            filename: photoFile.path.split('/').last,
          );
        }

        formData.files.add(MapEntry('photo', file));
      }

      final response = await _dio.patch('/menu/$id', data: formData);

      menuCache = null;
      _menuCacheTime = null;

      return ApiResponse.fromJson(
        response.data,
        (json) => Menu.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Menu.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Menu>> deleteMenu(int id) async {
    try {
      final response = await _dio.delete('/menu/$id');

      menuCache = null;
      _menuCacheTime = null;

      return ApiResponse.fromJson(
        response.data,
        (json) => Menu.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Menu.fromJson(json),
      );
    }
  }

  void clearMenuCache() {
    menuCache = null;
    _menuCacheTime = null;
  }
}
