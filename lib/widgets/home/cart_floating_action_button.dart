import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../screens/student/cart_screen.dart';

class CartFAB extends StatelessWidget {
  const CartFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cart = cartProvider.cart;
        if (cart == null || cart.items.isEmpty) return const SizedBox();

        final totalItems = cart.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );

        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
          icon: const Icon(Icons.shopping_cart),
          label: Row(
            children: [
              Text(
                '$totalItems item${totalItems > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18),
            ],
          ),
          backgroundColor: Color.fromRGBO(0, 204, 102, 0.9),
          elevation: 4,
          highlightElevation: 8,
        );
      },
    );
  }
}
