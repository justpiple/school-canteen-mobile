import 'package:intl/intl.dart';

class UpdateDiscountDto {
  final String? name;
  final double? percentage;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<int>? menus;

  UpdateDiscountDto({
    this.name,
    this.percentage,
    this.startDate,
    this.endDate,
    this.menus,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (percentage != null) 'percentage': percentage,
      if (startDate != null)
        'startDate': DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(startDate!),
      if (endDate != null)
        'endDate': DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(endDate!),
      if (menus != null) 'menus': menus,
    };
  }
}
