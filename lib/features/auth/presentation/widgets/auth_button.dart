import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  const AuthButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(400, 47),
        backgroundColor: AppPalette.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: TextStyle(color: AppPalette.white, fontSize: 18)),
          const SizedBox(width: 4),
          Image.asset('assets/icons/arrow.png', height: 60, width: 30),
        ],
      ),
    );
  }
}
