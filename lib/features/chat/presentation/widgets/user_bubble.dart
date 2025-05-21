import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class UserBubble extends StatelessWidget {
  final String message;

  const UserBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end, // Align to right
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.7, // Limit width to 70% of screen
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPalette.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPalette.borderColor),
            ),
            child: Text(message, style: TextStyle(color: AppPalette.textColor)),
          ),
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppPalette.mediumblue,
          child: Icon(Icons.person, color: Colors.white, size: 16),
        ),
      ],
    );
  }
}
