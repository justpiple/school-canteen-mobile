class Student {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? photo;
  final String userId;

  Student({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.photo,
    required this.userId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      photo: json['photo'],
      userId: json['userId'],
    );
  }
}