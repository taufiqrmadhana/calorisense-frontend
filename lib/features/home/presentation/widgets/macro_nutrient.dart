import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class MacronutrientSummaryWidget extends StatelessWidget {
  final Map<String, MacronutrientData> data;

  const MacronutrientSummaryWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              data.entries.map((entry) {
                return _MacroCard(name: entry.key, data: entry.value);
              }).toList(),
        ),
      ],
    );
  }
}

class MacronutrientData {
  final IconData icon;
  final int consumed;
  final int target;
  final Color backgroundColor;

  MacronutrientData({
    required this.icon,
    required this.consumed,
    required this.target,
    required this.backgroundColor,
  });
}

class _MacroCard extends StatelessWidget {
  final String name;
  final MacronutrientData data;

  const _MacroCard({required this.name, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 87,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: data.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 18, color: AppPalette.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: AppPalette.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.consumed}g',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppPalette.textColor,
            ),
          ),
          Text(
            'of ${data.target}g',
            style: const TextStyle(
              fontSize: 11,
              color: AppPalette.subTextColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
