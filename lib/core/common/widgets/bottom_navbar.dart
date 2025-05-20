import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class BottomNavBarWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavBarWidget({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.white,
        border: const Border(
          top: BorderSide(color: AppPalette.borderColor, width: 2),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            0,
            'Home',
            Icons.home_filled,
            Icons.home_outlined,
            context,
          ),
          _buildNavItem(1, 'Chat', Icons.chat, Icons.chat_outlined, context),
          _buildNavItem(
            2,
            'Reports',
            Icons.stacked_line_chart,
            Icons.stacked_line_chart,
            context,
          ),
          _buildNavItem(
            3,
            'Profile',
            Icons.person,
            Icons.person_outline,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label,
    IconData activeIcon,
    IconData inactiveIcon,
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
            Navigator.pushReplacementNamed(context, '/report');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/profile');
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? AppPalette.primaryColor : AppPalette.white,
              borderRadius: BorderRadius.circular(12),
              border: isActive ? null : Border.all(color: Colors.grey),
            ),
            child: Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? AppPalette.white : AppPalette.subTextColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  isActive ? AppPalette.primaryColor : AppPalette.subTextColor,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
