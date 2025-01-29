import 'discount.dart';

class Menu {
  final int id;
  final String name;
  final String description;
  final int price;
  final String type;
  final String photo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int standId;
  final Discount? discount;

  Menu({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.photo,
    required this.createdAt,
    required this.updatedAt,
    required this.standId,
    this.discount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'standId': standId,
      'name': name,
      'description': description,
      'photo': photo,
      'price': price,
      'discount': discount?.toJson(),
    };
  }

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      type: json['type'],
      photo: json['photo'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      standId: json['standId'],
      discount:
          json['discount'] != null ? Discount.fromJson(json['discount']) : null,
    );
  }

  Menu copyWith(
      {int? id,
      int? standId,
      String? name,
      String? description,
      String? photo,
      int? price,
      Discount? discount,
      String? type,
      DateTime? createdAt,
      DateTime? updatedAt}) {
    return Menu(
      id: id ?? this.id,
      standId: standId ?? this.standId,
      name: name ?? this.name,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
