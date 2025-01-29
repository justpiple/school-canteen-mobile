import 'package:dio/dio.dart';
import 'package:school_canteen/models/user.dart';
import '../models/api_response.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/register_response.dart';
import '../models/update_user.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio;
  final StorageService _storage;

  AuthService(this._dio, this._storage);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/signin', data: request.toJson());
      final loginResponse = LoginResponse.fromJson(response.data);

      if (loginResponse.statusCode == 200 &&
          loginResponse.accessToken != null) {
        await _storage.saveToken(loginResponse.accessToken!);
      }

      return loginResponse;
    } on DioError catch (e) {
      return LoginResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
      );
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post('/auth/signup', data: request.toJson());
      return RegisterResponse.fromJson(response.data);
    } on DioError catch (e) {
      return RegisterResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
      );
    }
  }

  Future<ApiResponse<dynamic>> updateUserInfo(UpdateUserDto dto) async {
    try {
      final response = await _dio.patch('/users/me', data: dto.toJson());
      return ApiResponse.fromJson(response.data, (json) => User.fromJson(json));
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        null,
      );
    }
  }

  Future<ApiResponse<User>> getUserInfo() async {
    try {
      final response = await _dio.get('/users/me');
      return ApiResponse.fromJson(response.data, (json) => User.fromJson(json));
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        null,
      );
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null;
  }
}
