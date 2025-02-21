import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class MyBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTabChange;

  const MyBottomNavBar({super.key, required this.selectedIndex, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: Colors.cyan.shade700,
      backgroundColor: Color.fromRGBO(13, 17, 23, 1),
      buttonBackgroundColor: Colors.cyan.shade700,
      onTap: onTabChange,
      items: [
        Icon(
          Icons.home_rounded,
          color: Colors.white
        ),
        Icon(
            Icons.wallet,
            color: Colors.white
        ),
        Icon(
          Icons.add,
          color: Colors.white
        ),
        Icon(
          Icons.bar_chart,
          color: Colors.white
        ),
        Icon(
            Icons.settings,
            color: Colors.white
        ),
      ],
    );
  }
}
