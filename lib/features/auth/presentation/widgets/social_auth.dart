import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/auth/presentation/widgets/social_icon.dart';
import 'package:flutter/material.dart';

class SocialAuthOptions extends StatelessWidget {
  const SocialAuthOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(thickness: 1, color: AppPalette.borderColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'or continue with',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppPalette.darkSubTextColor,
                ),
              ),
            ),
            const Expanded(
              child: Divider(thickness: 1, color: AppPalette.borderColor),
            ),
          ],
        ),
        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialIcon(assetPath: 'assets/icons/google.png', onTap: () {}),
            SizedBox(width: 25),
            SocialIcon(assetPath: 'assets/icons/facebook.png', onTap: () {}),
          ],
        ),
      ],
    );
  }
}
