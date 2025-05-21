import 'package:calorisense/features/chat/presentation/pages/chat_page.dart';
import 'package:calorisense/features/home/presentation/pages/burned.dart';
import 'package:calorisense/features/home/presentation/pages/intake.dart';
import 'package:calorisense/features/home/presentation/widgets/action_button.dart';
import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/features/home/presentation/widgets/daily_stats.dart';
import 'package:calorisense/features/home/presentation/widgets/meal_summary.dart';
import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:calorisense/core/common/cubits/app_user/app_user_cubit.dart';

class HomePage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => HomePage());
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data - nanti diganti dari domain layer
    final int consumedCalories = 1250;
    final int targetCalories = 2000;
    final int caloriesOut = 1000;
    final int caloriesTarget = 1500;

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
        automaticallyImplyLeading: false,
        backgroundColor: AppPalette.white,
        elevation: 0,
        title: GestureDetector(
          // onTap: () {
          //   Navigator.pushReplacement(context, HomePage.route());
          // },
          child: Image.asset('assets/images/image.png', height: 150),
        ),
        shape: const Border(
          bottom: BorderSide(width: 1, color: AppPalette.borderColor),
        ),
      ),
      body: BlocBuilder<AppUserCubit, AppUserState>(
        builder: (context, state) {
          String username = "User";

          if (state is AppUserLoggedIn) {
            username = state.user.name;
          }

          return SingleChildScrollView(
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
                                title: 'Calories Intake',
                                current: consumedCalories,
                                target: targetCalories,
                                unit: 'cal',
                                color: AppPalette.primaryColor,
                                backgroundColor: AppPalette.lightgreen,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CaloriesIntakePage.route(),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DailyStatsWidget(
                                icon: Icons.directions_run,
                                title: 'Calories Burned',
                                current: caloriesOut,
                                target: caloriesTarget,
                                unit: 'cal',
                                color: AppPalette.mediumorange,
                                backgroundColor: AppPalette.lightorange,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CaloriesBurnedPage.route(),
                                  );
                                },
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
                                onTap: () {
                                  Navigator.push(context, ChatPage.route());
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ActionButtonWidget(
                                icon: Icons.directions_run,
                                label: 'Add Activity',
                                backgroundColor: AppPalette.lightorange,
                                iconColor: AppPalette.mediumorange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CaloriesBurnedPage.route(),
                                  );
                                },
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
          );
        },
      ),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 0),
    );
  }
}
