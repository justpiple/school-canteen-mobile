import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_canteen/screens/stand_admin/home.dart';

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
    StandStatsPage(),
    StandStatsPage(),
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
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
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
                  height: _isMenuExpanded ? 160 : 64,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _isMenuExpanded
                      ? _buildExpandedMenu()
                      : _buildCompactMenu(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactMenu() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / 4;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
                width: itemWidth,
                child:
                    _buildNavItem(0, LucideIcons.layoutDashboard, 'Analytics')),
            SizedBox(
                width: itemWidth,
                child: _buildNavItem(1, LucideIcons.clipboardList, 'Orders')),
            SizedBox(
                width: itemWidth,
                child: _buildNavItem(4, LucideIcons.user, 'Profile')),
            SizedBox(width: itemWidth, child: _buildMoreButton()),
          ],
        );
      },
    );
  }

  Widget _buildExpandedMenu() {
    return Column(
      children: [
        SizedBox(
          height: 56,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 4;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                      width: itemWidth,
                      child: _buildNavItem(
                          0, LucideIcons.layoutDashboard, 'Analytics')),
                  SizedBox(
                      width: itemWidth,
                      child: _buildNavItem(
                          1, LucideIcons.clipboardList, 'Orders')),
                  SizedBox(
                      width: itemWidth,
                      child: _buildNavItem(4, LucideIcons.user, 'Profile')),
                  SizedBox(
                      width: itemWidth,
                      child: _buildNavItem(2, LucideIcons.menu, 'More')),
                ],
              );
            },
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 13),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
                      child: _buildAdditionalMenuItem(
                        icon: LucideIcons.utensils,
                        label: 'Manage Menu',
                        onTap: () => _onItemTapped(2),
                        isSelected: _selectedIndex == 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
                      child: _buildAdditionalMenuItem(
                        icon: LucideIcons.ticket,
                        label: 'Manage Discounts',
                        onTap: () => _onItemTapped(3),
                        isSelected: _selectedIndex == 3,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _isMenuExpanded = false),
                  style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
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
                            .withValues(alpha: 153),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Show less',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 153),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: FittedBox(
        fit: BoxFit.scaleDown,
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
                          .withValues(alpha: 153),
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
                          .withValues(alpha: 153),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 77),
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
