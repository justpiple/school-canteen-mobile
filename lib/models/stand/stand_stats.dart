class StandStats {
  final List<MonthlyIncome> monthlyIncome;
  final int totalOrders;
  final double averageIncomePerOrder;
  final int totalItemsSold;
  final List<TopSellingMenu> topSellingMenus;

  StandStats({
    required this.monthlyIncome,
    required this.totalOrders,
    required this.averageIncomePerOrder,
    required this.totalItemsSold,
    required this.topSellingMenus,
  });

  factory StandStats.fromJson(Map<String, dynamic> json) {
    return StandStats(
      monthlyIncome: (json['monthlyIncome'] as List)
          .map((e) => MonthlyIncome.fromJson(e))
          .toList()
          .sublist(6, 12),
      totalOrders: json['totalOrders'],
      averageIncomePerOrder: json['averageIncomePerOrder'].toDouble(),
      totalItemsSold: json['totalItemsSold'],
      topSellingMenus: (json['topSellingMenus'] as List)
          .map((e) => TopSellingMenu.fromJson(e))
          .toList(),
    );
  }
}

class MonthlyIncome {
  final String month;
  final int year;
  final int total;

  MonthlyIncome({
    required this.month,
    required this.year,
    required this.total,
  });

  factory MonthlyIncome.fromJson(Map<String, dynamic> json) {
    return MonthlyIncome(
      month: json['month'],
      year: json['year'],
      total: json['total'],
    );
  }
}

class TopSellingMenu {
  final int menuId;
  final String menuName;
  final int totalSold;
  final int totalIncome;

  TopSellingMenu({
    required this.menuId,
    required this.menuName,
    required this.totalSold,
    required this.totalIncome,
  });

  factory TopSellingMenu.fromJson(Map<String, dynamic> json) {
    return TopSellingMenu(
      menuId: json['menuId'],
      menuName: json['menuName'],
      totalSold: json['totalSold'],
      totalIncome: json['totalIncome'],
    );
  }
}
