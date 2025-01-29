import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/api_response.dart';
import '../../models/menu.dart';
import '../../models/stand.dart';
import '../../services/stand_service.dart';
import 'ending_soon_menu.dart';
import 'menu_card.dart';

class StandCard extends StatefulWidget {
  final Stand stand;

  const StandCard({required this.stand, super.key});

  @override
  State<StandCard> createState() => _StandCardState();
}

class _StandCardState extends State<StandCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: _buildStandHeader(context),
          ),
          if (_isExpanded) _buildMenuList(context),
        ],
      ),
    );
  }

  Widget _buildStandHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(
          top: const Radius.circular(16),
          bottom: _isExpanded ? Radius.zero : const Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.stand.standName[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.stand.standName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.stand.ownerName,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return FutureBuilder<ApiResponse<List<Menu>>>(
      future: Provider.of<StandService>(context, listen: false)
          .getStandMenu(widget.stand.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Failed to load menu'),
            ),
          );
        }

        final menus = snapshot.data!.data!;
        final endingSoonMenus = menus
            .where((menu) =>
                menu.discount != null &&
                menu.discount!.endDate.difference(DateTime.now()).inDays <= 2)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (endingSoonMenus.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Ending Soon!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: endingSoonMenus.length,
                  itemBuilder: (context, index) => SizedBox(
                    width: 280,
                    child: EndingSoonMenuCard(menu: endingSoonMenus[index]),
                  ),
                ),
              ),
            ],
            ListView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: menus.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MenuCard(menu: menus[index]),
              ),
            ),
          ],
        );
      },
    );
  }
}
