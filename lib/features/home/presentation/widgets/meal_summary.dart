import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class MealSummaryWidget extends StatelessWidget {
  final String type;
  final String time;
  final String description;
  final int calories;

  const MealSummaryWidget({
    super.key,
    required this.type,
    required this.time,
    required this.description,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMealBackgroundColor(type),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                _getMealIcon(type),
                color: _getMealColor(type),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Meal details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppPalette.subTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppPalette.subTextColor,
                  ),
                ),
              ],
            ),
          ),

          // Calories
          Text(
            "$calories cal",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppPalette.textColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  Color _getMealColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.amber.shade700;
      case 'lunch':
        return Colors.deepOrange;
      case 'dinner':
        return Colors.purple;
      case 'snack':
        return Colors.lightGreen;
      default:
        return AppPalette.primaryColor;
    }
  }

  Color _getMealBackgroundColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.amber.shade100; // Latar yang lebih terang untuk amber
      case 'lunch':
        return Colors.deepOrange.shade100; // Latar yang ringan untuk orange
      case 'dinner':
        return Colors.purple.shade100; // Ungu lembut untuk dinner
      case 'snack':
        return Colors.lightGreen.shade100; // Latar hijau pucat
      default:
        return AppPalette.primaryColor;
    }
  }
}
