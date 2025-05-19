import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/home/presentation/widgets/daily_stats.dart';
import 'package:calorisense/features/home/presentation/widgets/macro_nutrient.dart';
import 'package:calorisense/features/home/presentation/widgets/meal_card.dart';
import 'package:flutter/material.dart';

class TodayNutritionPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const TodayNutritionPage());
  const TodayNutritionPage({super.key});

  @override
  State<TodayNutritionPage> createState() => _TodayNutritionPageState();
}

class _TodayNutritionPageState extends State<TodayNutritionPage> {
  final int consumedCalories = 1250;
  final int targetCalories = 2000;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today\'s Nutrition',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppPalette.white,
        shape: const Border(
          bottom: BorderSide(width: 1, color: AppPalette.borderColor),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // Fill full height
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Daily goal section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: AppPalette.borderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DailyStatsWidget(
                          icon: Icons.local_fire_department_outlined,
                          title: 'Daily Goal',
                          current: consumedCalories,
                          target: targetCalories,
                          unit: 'cal',
                          color: AppPalette.primaryColor,
                          backgroundColor: AppPalette.lightgreen,
                        ),
                      ),
                    ),

                    // Macronutrients section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: AppPalette.borderColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Macro Nutrients",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.textColor,
                              ),
                            ),
                            MacronutrientSummaryWidget(
                              data: {
                                'Carbs': MacronutrientData(
                                  icon: Icons.bakery_dining,
                                  consumed: 156,
                                  target: 250,
                                  backgroundColor: Color(0xFFDCEEFB),
                                ),
                                'Protein': MacronutrientData(
                                  icon: Icons.restaurant_menu,
                                  consumed: 45,
                                  target: 60,
                                  backgroundColor: Color(0xFFFDEAEA),
                                ),
                                'Fats': MacronutrientData(
                                  icon: Icons.ramen_dining,
                                  consumed: 35,
                                  target: 55,
                                  backgroundColor: Color(0xFFFFF4D6),
                                ),
                                'Fiber': MacronutrientData(
                                  icon: Icons.grass,
                                  consumed: 20,
                                  target: 30,
                                  backgroundColor: Color(0xFFE6F4EA),
                                ),
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Meal section
                    ExpandedSection(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: AppPalette.borderColor,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Today's Summary",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppPalette.textColor,
                                ),
                              ),
                              SizedBox(height: 16),
                              MealCard(
                                foodName: 'Oatmeal with banana',
                                calories: 250,
                                macros: {
                                  'Carbs': '45g',
                                  'Protein': '8g',
                                  'Fat': '5g',
                                  'Fiber': '4g',
                                },
                                micronutrients: {
                                  'Vitamin B6': '0.2mg (15%)',
                                  'Magnesium': '56mg (13%)',
                                  'Zinc': '2mg (18%)',
                                },
                              ),
                              MealCard(
                                foodName: 'Black coffee',
                                calories: 70,
                                macros: {},
                                micronutrients: {},
                              ),
                              MealCard(
                                foodName: 'Grilled Chicken Salad',
                                calories: 250,
                                macros: {
                                  'Carbs': '45g',
                                  'Protein': '8g',
                                  'Fat': '5g',
                                  'Fiber': '4g',
                                },
                                micronutrients: {
                                  'Vitamin B6': '0.2mg (15%)',
                                  'Magnesium': '56mg (13%)',
                                  'Zinc': '2mg (18%)',
                                },
                              ),
                              MealCard(
                                foodName: 'Grilled Chicken Salad',
                                calories: 250,
                                macros: {
                                  'Carbs': '45g',
                                  'Protein': '8g',
                                  'Fat': '5g',
                                  'Fiber': '4g',
                                },
                                micronutrients: {
                                  'Vitamin B6': '0.2mg (15%)',
                                  'Magnesium': '56mg (13%)',
                                  'Zinc': '2mg (18%)',
                                },
                              ),
                              MealCard(
                                foodName: 'Grilled Chicken Salad',
                                calories: 250,
                                macros: {
                                  'Carbs': '45g',
                                  'Protein': '8g',
                                  'Fat': '5g',
                                  'Fiber': '4g',
                                },
                                micronutrients: {
                                  'Vitamin B6': '0.2mg (15%)',
                                  'Magnesium': '56mg (13%)',
                                  'Zinc': '2mg (18%)',
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ExpandedSection extends StatelessWidget {
  final Widget child;

  const ExpandedSection({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: child); // or remove if not in a Flex
  }
}
