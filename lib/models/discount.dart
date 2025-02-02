class Discount {
  final int id;
  final int standId;
  final String name;
  final int percentage;
  final DateTime startDate;
  final DateTime endDate;

  Discount({
    required this.id,
    required this.standId,
    required this.name,
    required this.percentage,
    required this.startDate,
    required this.endDate,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'],
      standId: json['standId'],
      name: json['name'],
      percentage: json['percentage'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'standId': standId,
      'name': name,
      'percentage': percentage,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
