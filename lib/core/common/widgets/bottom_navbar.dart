import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavBarWidget({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.white,
        border: Border(
          top: BorderSide(color: AppPalette.borderColor, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Home', Icons.home, context),
          _buildNavItem(1, 'Chat', Icons.chat, context),
          _buildNavItem(2, 'Profile', Icons.person, context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/chat');
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppPalette.primaryColor : AppPalette.subTextColor,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive ? AppPalette.primaryColor : AppPalette.subTextColor,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: 50,
            decoration: BoxDecoration(
              color: isActive ? AppPalette.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: AppPalette.primaryColor,
                          blurRadius: 3,
                          spreadRadius: 0.2,
                        ),
                      ]
                      : [],
            ),
          ),
        ],
      ),
    );
  }
}
