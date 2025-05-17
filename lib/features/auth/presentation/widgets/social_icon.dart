import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';

class SocialIcon extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const SocialIcon({super.key, required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppPalette.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Image.asset(assetPath, height: 24)),
      ),
    );
  }
}
