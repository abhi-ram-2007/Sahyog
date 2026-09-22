import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFDDE3EA),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavigationItem(
              icon: Icons.home_outlined,
              label: 'Home',
              selected: selectedIndex == 0,
            ),
            _NavigationItem(
              icon: Icons.search,
              label: 'Explore',
              selected: selectedIndex == 1,
            ),
            _NavigationItem(
              icon: Icons.add_circle_outline,
              label: 'Add',
              selected: selectedIndex == 2,
            ),
            _NavigationItem(
              icon: Icons.description_outlined,
              label: 'Track',
              selected: selectedIndex == 3,
            ),
            _NavigationItem(
              icon: Icons.person_outline,
              label: 'Profile',
              selected: selectedIndex == 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? const Color(0xFF078B49)
        : const Color(0xFF71839F);

    return SizedBox(
      width: 65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 27,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}