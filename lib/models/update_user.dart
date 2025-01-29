class UpdateUserDto {
  final String? username;
  final String? password;
  final String? role;

  UpdateUserDto({
    this.username,
    this.password,
    this.role,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (username != null) data['username'] = username;
    if (password != null) data['password'] = password;
    if (role != null) data['role'] = role;
    return data;
  }
}