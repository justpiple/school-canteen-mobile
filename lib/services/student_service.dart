import 'package:dio/dio.dart';
import 'dart:io';
import '../models/student/create_student.dart';
import '../models/student/student.dart';
import '../models/api_response.dart';
import '../models/student/update_student.dart';

class StudentService {
  final Dio _dio;

  StudentService(this._dio);

  Future<ApiResponse<Student>> getProfile() async {
    try {
      final response = await _dio.get('/students/me');
      return ApiResponse.fromJson(
        response.data,
        (json) => Student.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Student.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Student>> createProfile(CreateStudentDto dto,
      {File? photoFile}) async {
    try {
      FormData formData = FormData.fromMap({
        'name': dto.name,
        'address': dto.address,
        'phone': dto.phone,
        if (dto.userId != null) 'userId': dto.userId,
      });

      if (photoFile != null) {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(
              photoFile.path,
              filename: photoFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/students',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => Student.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Student.fromJson(json),
      );
    }
  }

  Future<ApiResponse<Student>> updateProfile(UpdateStudentDto dto,
      {File? photoFile}) async {
    try {
      FormData formData = FormData.fromMap({
        if (dto.name != null) 'name': dto.name,
        if (dto.address != null) 'address': dto.address,
        if (dto.phone != null) 'phone': dto.phone,
        if (dto.userId != null) 'userId': dto.userId,
      });

      if (photoFile != null) {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(
              photoFile.path,
              filename: photoFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.patch(
        '/students/me',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => Student.fromJson(json),
      );
    } on DioError catch (e) {
      return ApiResponse.fromJson(
        e.response?.data ?? {'statusCode': e.response?.statusCode ?? 500},
        (json) => Student.fromJson(json),
      );
    }
  }
}
