import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavBarWidget({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppPalette.white),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: AppPalette.white,
        selectedItemColor: AppPalette.primaryColor,
        unselectedItemColor: AppPalette.subTextColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_line_chart),
            activeIcon: Icon(Icons.stacked_line_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Will be implemented later with navigation functionality
          // and potentially BLoC for state management
        },
      ),
    );
  }
}
