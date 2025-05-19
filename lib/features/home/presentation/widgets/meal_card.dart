import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class MealCard extends StatefulWidget {
  final String foodName;
  final int calories;
  final Map<String, String> macros;
  final Map<String, String> micronutrients;

  const MealCard({
    super.key,
    required this.foodName,
    required this.calories,
    required this.macros,
    required this.micronutrients,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppPalette.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.foodName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppPalette.textColor,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${widget.calories} cal',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppPalette.textColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppPalette.subTextColor,
                    ),
                  ],
                ),
              ],
            ),

            if (_isExpanded) ...[
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    widget.macros.entries.map((entry) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppPalette.lightblue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppPalette.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    widget.micronutrients.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppPalette.textColor,
                              ),
                            ),
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppPalette.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
