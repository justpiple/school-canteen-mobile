import 'package:dio/dio.dart';
import 'storage_service.dart';

class DioInstance {
  static final DioInstance _instance = DioInstance._internal();
  late Dio dio;
  late StorageService _storage;

  factory DioInstance({required StorageService storage}) {
    _instance._storage = storage;
    return _instance;
  }

  DioInstance._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'https://canteen-api.benspace.xyz/v1',
      connectTimeout: const Duration(seconds: 60).inMilliseconds,
      receiveTimeout: const Duration(seconds: 60).inMilliseconds,
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
