class CreateDiscountDto {
  final String name;
  final double percentage;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> menus;

  CreateDiscountDto({
    required this.name,
    required this.percentage,
    required this.startDate,
    required this.endDate,
    required this.menus,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percentage': percentage,
      'startDate': "${startDate.toIso8601String()}Z",
      'endDate': "${endDate.toIso8601String()}Z",
      'menus': menus,
    };
  }
}
