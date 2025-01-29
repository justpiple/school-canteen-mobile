class Stand {
  final int id;
  final String standName;
  final String ownerName;
  final String phone;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Stand({
    required this.id,
    required this.standName,
    required this.ownerName,
    required this.phone,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Stand.fromJson(Map<String, dynamic> json) {
    return Stand(
      id: json['id'],
      standName: json['standName'],
      ownerName: json['ownerName'],
      phone: json['phone'],
      ownerId: json['ownerId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
