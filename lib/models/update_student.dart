class UpdateStudentDto {
  final String? name;
  final String? address;
  final String? phone;
  final String? photo;
  final String? userId;

  UpdateStudentDto({
    this.name,
    this.address,
    this.phone,
    this.photo,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (photo != null) data['photo'] = photo;
    if (userId != null) data['userId'] = userId;
    return data;
  }
}