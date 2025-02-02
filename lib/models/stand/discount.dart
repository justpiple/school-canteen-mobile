import '../menu.dart';

class Discount {
  final int id;
  final int standId;
  final String name;
  final double percentage;
  final DateTime startDate;
  final DateTime endDate;
  final List<Menu>? menus;

  Discount({
    required this.id,
    required this.standId,
    required this.name,
    required this.percentage,
    required this.startDate,
    required this.endDate,
    this.menus,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      standId: json['standId'],
      name: json['name'],
      percentage: json['percentage'].toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      menus: json['menus'] != null
          ? (json['menus'] as List).map((e) => Menu.fromJson(e)).toList()
          : null,
    );
  }
}
