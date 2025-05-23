import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppPalette.gradient3, // Placeholder
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32, color: AppPalette.white),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.mediumblue,
                  ),
                ),
                Text(
                  userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppPalette.textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
