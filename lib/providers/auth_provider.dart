import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:school_canteen/models/register_response.dart';

import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/update_user.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  LoginResponse? loginResponse;
  User? user;
  Role? role;
  bool isLoading = false;
  bool isAuthenticated = false;

  AuthProvider(this._authService);

  Future<bool> login(String username, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      loginResponse = await _authService.login(
        LoginRequest(username: username, password: password),
      );

      if (loginResponse?.statusCode == 200) {
        await _getUserInfo();
        isAuthenticated = true;
        role = loginResponse?.role;
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<RegisterResponse> register(
      String username, String password, Role role) async {
    isLoading = true;
    notifyListeners();

    try {
      final registerResponse = await _authService.register(
        RegisterRequest(username: username, password: password, role: role),
      );
      return registerResponse;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserInfo(UpdateUserDto dto) async {
    final response = await _authService.updateUserInfo(dto);
    if (response.isSuccess) {
      user = response.data;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _clearAuthState();
  }

  Future<bool> checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final success = await _getUserInfo();
      isAuthenticated = success;
      notifyListeners();
    }
    return isAuthenticated;
  }

  Future<bool> _getUserInfo() async {
    final response = await _authService.getUserInfo();
    if (response.isSuccess && response.data != null) {
      user = response.data;
      role = response.data?.role;
      return true;
    }
    return false;
  }

  void _clearAuthState() {
    user = null;
    loginResponse = null;
    isAuthenticated = false;
    role = null;
    notifyListeners();
  }
}
