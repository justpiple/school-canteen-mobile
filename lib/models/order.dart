class OrderList {
  final List<Order> orders;

  OrderList({required this.orders});

  factory OrderList.fromJson(List<dynamic> json) {
    final List<dynamic> ordersJson = json;
    return OrderList(
      orders: ordersJson.map((orderJson) => Order.fromJson(orderJson)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return orders.map((order) => order.toJson()).toList();
  }
}

class Order {
  final int id;
  final String userId;
  final int standId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final String standName;
  final String studentName;

  Order({
    required this.id,
    required this.userId,
    required this.standId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.standName,
    required this.studentName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      userId: json['userId'] as String,
      standId: json['standId'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      standName: json['stand']['standName'] as String,
      studentName: json['user']['student']['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'standId': standId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'stand': standName,
      'studentName': studentName
    };
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int menuId;
  final String menuName;
  final int quantity;
  final int price;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      menuId: json['menuId'] as int,
      menuName: json['menuName'] as String,
      quantity: json['quantity'] as int,
      price: json['price'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'menuId': menuId,
      'menuName': menuName,
      'quantity': quantity,
      'price': price,
    };
  }
}
