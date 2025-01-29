import 'login_response.dart';

class User {
  final String? id;
  final String? username;
  final Role? role;

  User({
    this.username,
    this.id,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String? roleStr = json['data']?['role'];
    Role? role;
    if (roleStr != null) {
      role = Role.values.byName(roleStr);
    }

    return User(id: json['id'], username: json['username'], role: role);
  }
}
