import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../models/menu.dart';
import '../../providers/cart_provider.dart';

class AddToCartButton extends StatelessWidget {
  final Menu menu;

  const AddToCartButton({required this.menu, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cart = cartProvider.cart;
        final quantity = cart?.items
            .where((item) => item.menu.id == menu.id)
            .fold(0, (sum, item) => sum + item.quantity);

        if (quantity != null && quantity > 0) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.minus,
                      color: Colors.white, size: 16),
                  onPressed: () => cartProvider.decrementItem(menu),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.plus,
                      color: Colors.white, size: 16),
                  onPressed: () => cartProvider.incrementItem(menu),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          );
        }

        return ElevatedButton(
          onPressed: () async {
            if (cart != null && cart.standId != menu.standId) {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Change Stand?'),
                  content: const Text(
                    'Your cart contains items from another stand. Adding this item will clear your current cart.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;
              cartProvider.clearCart();
            }
            cartProvider.addItem(menu);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Add'),
        );
      },
    );
  }
}
