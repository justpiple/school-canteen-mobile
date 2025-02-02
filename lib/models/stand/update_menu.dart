class UpdateMenuDto {
  final String? name;
  final String? description;
  final int? price;
  final String? type;

  UpdateMenuDto({
    this.name,
    this.description,
    this.price,
    this.type,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (type != null) data['type'] = type;
    return data;
  }
}
