import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../models/api_response.dart';
import '../models/student/create_student.dart';
import '../models/student/student.dart';
import '../models/student/update_student.dart';
import '../services/student_service.dart';

class ProfileProvider extends ChangeNotifier {
  final StudentService _studentService;
  ApiResponse<Student>? studentProfile;
  DateTime? _lastFetch;
  static const cacheDuration = Duration(minutes: 2);

  ProfileProvider(this._studentService);

  Future<String> createStudentProfile({
    required String name,
    required String address,
    required String phone,
    File? photoFile,
  }) async {
    final response = await _studentService.createProfile(
      CreateStudentDto(
        name: name,
        address: address,
        phone: phone,
      ),
      photoFile: photoFile,
    );

    if (response.isSuccess) {
      studentProfile = response;
      notifyListeners();
    }
    return response.message;
  }

  Future<String> updateStudentProfile(UpdateStudentDto dto,
      {File? photoFile}) async {
    final response =
        await _studentService.updateProfile(dto, photoFile: photoFile);
    if (response.isSuccess) {
      studentProfile = response;
      notifyListeners();
    }
    return response.message;
  }

  Future<void> loadProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && studentProfile != null && _lastFetch != null) {
      final difference = DateTime.now().difference(_lastFetch!);
      if (difference < cacheDuration) {
        return;
      }
    }

    final response = await _studentService.getProfile();
    if (response.isSuccess) {
      studentProfile = response;
      _lastFetch = DateTime.now();
      notifyListeners();
    }
  }

  void clearCache() {
    studentProfile = null;
    _lastFetch = null;
    notifyListeners();
  }

  void clearProfile() {
    studentProfile = null;
    notifyListeners();
  }
}
