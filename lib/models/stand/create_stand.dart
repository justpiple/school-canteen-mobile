class CreateStandDto {
  final String standName;
  final String ownerName;
  final String phone;

  CreateStandDto({
    required this.standName,
    required this.ownerName,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'standName': standName,
      'ownerName': ownerName,
      'phone': phone,
    };
  }
}
