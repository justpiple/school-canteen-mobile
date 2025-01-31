class CreateStudentDto {
  final String name;
  final String address;
  final String phone;
  final String? photo;
  final String? userId;

  CreateStudentDto({
    required this.name,
    required this.address,
    required this.phone,
    this.photo,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      if (photo != null) 'photo': photo,
      if (userId != null) 'userId': userId,
    };
  }
}