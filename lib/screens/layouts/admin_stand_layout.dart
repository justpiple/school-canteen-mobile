import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_canteen/screens/stand_admin/home_screen.dart';
import 'package:school_canteen/screens/stand_admin/profile_screen.dart';
import 'package:school_canteen/screens/student/order_screen.dart';

class AdminStandLayout extends StatefulWidget {
  const AdminStandLayout({super.key});

  @override
  State<AdminStandLayout> createState() => _AdminStandLayoutState();
}

class _AdminStandLayoutState extends State<AdminStandLayout> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = false;

  final List<Widget> _pages = const [
    StandStatsPage(),
    OrderHistoryPage(),
    StandProfilePage(),
    StandStatsPage(),
    StandStatsPage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
      _isMenuExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .08),
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isMenuExpanded ? 170 : 64,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  height: 170,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 64,
                        child: _buildCompactMenu(),
                      ),
                      if (_isMenuExpanded) ...[
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: .05),
                        ),
                        Expanded(
                          child: _buildExpandedMenuItems(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactMenu() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / 5;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          spacing: 2,
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildNavItem(0, LucideIcons.layoutDashboard, 'Analytics'),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildNavItem(1, LucideIcons.clipboardList, 'Orders'),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildNavItem(2, LucideIcons.user, 'Profile'),
            ),
            SizedBox(
              width: itemWidth,
              child: _buildMoreButton(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpandedMenuItems() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAdditionalMenuItem(
                  icon: LucideIcons.utensils,
                  label: 'Manage Menu',
                  onTap: () => _onItemTapped(2),
                  isSelected: _selectedIndex == 3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAdditionalMenuItem(
                  icon: LucideIcons.ticket,
                  label: 'Manage Discounts',
                  onTap: () => _onItemTapped(3),
                  isSelected: _selectedIndex == 4,
                ),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _isMenuExpanded = false),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.chevronsUp,
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .6),
                ),
                const SizedBox(width: 4),
                Text(
                  'Show less',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: .6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreButton() {
    return _buildBaseNavItem(
      onTap: () => setState(() => _isMenuExpanded = true),
      icon: LucideIcons.menu,
      label: 'More',
      isSelected: _isMenuExpanded,
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return _buildBaseNavItem(
      onTap: () => _onItemTapped(index),
      icon: icon,
      label: label,
      isSelected: _selectedIndex == index,
    );
  }

  Widget _buildBaseNavItem({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .6),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: .6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: .3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
