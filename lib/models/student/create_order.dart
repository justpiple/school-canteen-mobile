class CreateOrderResponse {
  final int id;
  final String userId;
  final int standId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CreateOrderItem> items;
  final int totalPrice;

  CreateOrderResponse({
    required this.id,
    required this.userId,
    required this.standId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    required this.totalPrice,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      id: json['id'],
      userId: json['userId'],
      standId: json['standId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      items: (json['items'] as List)
          .map((item) => CreateOrderItem.fromJson(item))
          .toList(),
      totalPrice: json['totalPrice'],
    );
  }
}

class CreateOrderItem {
  final int menuId;
  final int quantity;
  final int price;

  CreateOrderItem({
    required this.menuId,
    required this.quantity,
    required this.price,
  });

  factory CreateOrderItem.fromJson(Map<String, dynamic> json) {
    return CreateOrderItem(
      menuId: json['menuId'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}
