import 'package:flutter/material.dart';
import '../Directory/core/theme.dart';

class OakeyBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const OakeyBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: OakeyTheme.borderLine, width: 1.0),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,

        backgroundColor: OakeyTheme.backgroundMain,
        selectedItemColor: OakeyTheme.primaryDeep,
        unselectedItemColor: OakeyTheme.textHint,

        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),

        type: BottomNavigationBarType.fixed,
        elevation: 0,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 24),
            activeIcon: Icon(Icons.home, size: 24),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.liquor_outlined, size: 24),
            activeIcon: Icon(Icons.liquor, size: 24),
            label: 'LIST',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline, size: 24),
            activeIcon: Icon(Icons.lightbulb, size: 24),
            label: 'PICK',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'MY',
          ),
        ],
      ),
    );
  }
}
