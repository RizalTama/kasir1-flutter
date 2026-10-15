import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../strings.dart';
import '../theme/app_colors.dart';
import 'responsive.dart';

class _ShellDestination {
  const _ShellDestination(this.path, this.label, this.icon, this.iconFilled);

  final String path;
  final String label;
  final IconData icon;
  final IconData iconFilled;
}

const _destinations = [
  _ShellDestination(
    '/pos',
    AppStrings.navKasir,
    Icons.point_of_sale_outlined,
    Icons.point_of_sale,
  ),
  _ShellDestination(
    '/products',
    AppStrings.navProduk,
    Icons.inventory_2_outlined,
    Icons.inventory_2,
  ),
  _ShellDestination(
    '/reports',
    AppStrings.navLaporan,
    Icons.bar_chart_outlined,
    Icons.bar_chart,
  ),
  _ShellDestination(
    '/settings',
    AppStrings.navPengaturan,
    Icons.settings_outlined,
    Icons.settings,
  ),
];

/// Shell navigasi responsif: sidebar navy di tablet, bottom nav di HP
/// (§4.5 Claude.md).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    final index = _destinations.indexWhere(
      (d) => location.startsWith(d.path),
    );
    return index == -1 ? 0 : index;
  }

  void _onSelect(BuildContext context, int index) {
    context.go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _indexForLocation(location);
    final width = MediaQuery.sizeOf(context).width;

    if (isTabletWidth(width)) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
              selectedIndex: selectedIndex,
              onSelect: (i) => _onSelect(context, i),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _onSelect(context, i),
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.iconFilled),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          for (var i = 0; i < _destinations.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _SidebarItem(
                destination: _destinations[i],
                selected: i == selectedIndex,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          selected ? destination.iconFilled : destination.icon,
          color: selected ? AppColors.navy : AppColors.mutedOnDark,
        ),
      ),
    );
  }
}
