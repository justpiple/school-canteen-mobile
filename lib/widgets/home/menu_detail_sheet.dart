import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/menu.dart';
import 'add_to_card.dart';

class MenuDetailSheet extends StatelessWidget {
  final Menu menu;
  final ScrollController scrollController;

  const MenuDetailSheet({
    required this.menu,
    required this.scrollController,
    super.key,
  });

  String _formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = menu.discount != null &&
        menu.discount!.startDate.isBefore(DateTime.now()) &&
        menu.discount!.endDate.isAfter(DateTime.now());

    final discountedPrice = hasDiscount
        ? menu.price * (100 - menu.discount!.percentage) ~/ 100
        : menu.price;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Hero(
            tag: 'menu-${menu.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                menu.photo,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            menu.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            menu.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_offer, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${menu.discount!.name} - ${menu.discount!.percentage}% OFF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valid until ${DateFormat('dd MMMM yyyy').format(menu.discount!.endDate)}',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasDiscount)
                      Text(
                        _formatCurrency(menu.price),
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    Text(
                      _formatCurrency(discountedPrice),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 160,
                child: AddToCartButton(menu: menu),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
