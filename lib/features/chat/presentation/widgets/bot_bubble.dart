import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class BotBubble extends StatelessWidget {
  final String message;

  const BotBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppPalette.orange,
          child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenWidth * 0.7),
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
      ],
    );
  }
}
