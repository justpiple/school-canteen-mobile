import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/menu.dart';
import 'add_to_card.dart';
import 'menu_detail_sheet.dart';

class MenuCard extends StatelessWidget {
  final Menu menu;

  const MenuCard({required this.menu, super.key});

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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMenuDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuImage(hasDiscount),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menu.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          menu.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasDiscount)
                        Text(
                          _formatCurrency(menu.price),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        _formatCurrency(discountedPrice),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 120,
                    child: AddToCartButton(menu: menu),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuImage(bool hasDiscount) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            menu.photo,
            height: 80,
            width: 80,
            fit: BoxFit.cover,
          ),
        ),
        if (hasDiscount)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${menu.discount!.percentage}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showMenuDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) =>
            MenuDetailSheet(menu: menu, scrollController: scrollController),
      ),
    );
  }
}
