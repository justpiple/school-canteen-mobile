class CreateMenuDto {
  final String name;
  final String? description;
  final int price;
  final String type;

  CreateMenuDto({
    required this.name,
    this.description,
    required this.price,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'type': type
    };
    return data;
  }
}
