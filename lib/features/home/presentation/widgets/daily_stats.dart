import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class DailyStatsWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final int current;
  final int target;
  final String unit;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const DailyStatsWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = current / target;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$current',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppPalette.textColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ $target $unit',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppPalette.darkSubTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppPalette.white,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
