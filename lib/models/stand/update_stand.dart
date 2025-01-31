class UpdateStandDto {
  final String? standName;
  final String? ownerName;
  final String? phone;

  UpdateStandDto({
    this.standName,
    this.ownerName,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      if (standName != null) 'standName': standName,
      if (ownerName != null) 'ownerName': ownerName,
      if (phone != null) 'phone': phone,
    };
  }
}
