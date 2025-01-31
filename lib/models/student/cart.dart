import '../menu.dart';

class CartItem {
  final Menu menu;
  int quantity;

  CartItem({
    required this.menu,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'menuId': menu.id,
      'quantity': quantity,
    };
  }
}

class Cart {
  final int standId;
  final List<CartItem> items;

  Cart({
    required this.standId,
    required this.items,
  });

  double get total {
    return items.fold(0, (sum, item) {
      double price = item.menu.price.toDouble();
      if (item.menu.discount != null) {
        final discount = item.menu.discount!;
        if (discount.startDate.isBefore(DateTime.now()) &&
            discount.endDate.isAfter(DateTime.now())) {
          price = price * (100 - discount.percentage) / 100;
        }
      }
      return sum + (price * item.quantity);
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'standId': standId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
