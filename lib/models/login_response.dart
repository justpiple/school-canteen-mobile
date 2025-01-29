enum Role { STUDENT, ADMIN_STAND }

class LoginResponse {
  final String? message;
  final String? error;
  final int statusCode;
  final String? accessToken;
  final String? id;
  final String? username;
  final Role? role;

  LoginResponse({
    this.message,
    this.error,
    required this.statusCode,
    this.accessToken,
    this.id,
    this.username,
    this.role,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    String? roleStr = json['data']?['role'];
    Role? role;
    if (roleStr != null) {
      role = Role.values.byName(roleStr);
    }

    return LoginResponse(
      message: json['message'],
      error: json['error'],
      statusCode: json['statusCode'],
      accessToken: json['data']?['access_token'],
      id: json['data']?['id'],
      username: json['data']?['username'],
      role: role,
    );
  }
}