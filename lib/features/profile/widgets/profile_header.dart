import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Later replace with dynamic data
    const String username = "Mas Azril";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $username!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppPalette.textColor,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Profile page',
          style: TextStyle(fontSize: 16, color: AppPalette.darkSubTextColor),
        ),
      ],
    );
  }
}
