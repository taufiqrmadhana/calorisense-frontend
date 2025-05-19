import 'package:calorisense/features/home/presentation/pages/today_nutrition.dart';
import 'package:calorisense/features/home/presentation/widgets/action_button.dart';
import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/features/home/presentation/widgets/daily_stats.dart';
import 'package:calorisense/features/home/presentation/widgets/meal_summary.dart';
import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';

class HomePage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => HomePage());
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - nanti diganti dari domain layer
    final String username = "MadGun";
    final int consumedCalories = 1250;
    final int targetCalories = 2000;
    final int waterIntake = 5;
    final int waterTarget = 8;

    final List<Map<String, dynamic>> meals = [
      {
        'type': 'Breakfast',
        'time': '7:30 AM',
        'description': 'Toast with eggs, Orange juice',
        'calories': 350,
      },
      {
        'type': 'Lunch',
        'time': '12:15 PM',
        'description': 'Nasi goreng, Mixed vegetables',
        'calories': 450,
      },
      {
        'type': 'Snack',
        'time': '3:00 PM',
        'description': 'Yogurt with granola and berries',
        'calories': 200,
      },
      {
        'type': 'Dinner',
        'time': '7:00 PM',
        'description': 'Grilled chicken, Steamed broccoli, Rice',
        'calories': 500,
      },
      {
        'type': 'Breakfast',
        'time': '8:00 AM',
        'description': 'Oatmeal with banana and honey',
        'calories': 320,
      },
    ];

    return Scaffold(
      backgroundColor: AppPalette.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppPalette.white,
        elevation: 0,
        title: Image.asset('assets/images/image.png', height: 150),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
        ],
        shape: const Border(
          bottom: BorderSide(width: 1, color: AppPalette.borderColor),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, $username!",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Let's track your health journey today",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppPalette.darkSubTextColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: DailyStatsWidget(
                            icon: Icons.local_fire_department_outlined,
                            title: 'Daily Goal',
                            current: consumedCalories,
                            target: targetCalories,
                            unit: 'cal',
                            color: AppPalette.primaryColor,
                            backgroundColor: AppPalette.lightgreen,
                            onPressed: () {
                              Navigator.push(
                                context,
                                TodayNutritionPage.route(),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DailyStatsWidget(
                            icon: Icons.water_drop_outlined,
                            title: 'Water Intake',
                            current: waterIntake,
                            target: waterTarget,
                            unit: 'glasses',
                            color: Colors.blue,
                            backgroundColor: AppPalette.lightblue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ActionButtonWidget(
                            icon: Icons.restaurant_outlined,
                            label: 'Add Meal',
                            backgroundColor: AppPalette.lightgreen,
                            iconColor: AppPalette.primaryColor,
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ActionButtonWidget(
                            icon: Icons.water_drop_outlined,
                            label: 'Add Water',
                            backgroundColor: AppPalette.lightblue,
                            iconColor: Colors.blue,
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...meals.map(
                    (meal) => MealSummaryWidget(
                      type: meal['type'],
                      time: meal['time'],
                      description: meal['description'],
                      calories: meal['calories'],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 0),
    );
  }
}
