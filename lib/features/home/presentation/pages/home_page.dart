import 'dart:async';
import 'package:flutter/material.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/chat/presentation/pages/chat_page.dart';
import 'package:calorisense/features/home/presentation/pages/burned.dart';
import 'package:calorisense/features/home/presentation/pages/intake.dart';
import 'package:calorisense/features/home/presentation/widgets/action_button.dart';
import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/features/home/presentation/widgets/daily_stats.dart';
import 'package:calorisense/features/home/presentation/widgets/meal_summary.dart';
import 'package:calorisense/services/health_service.dart';

class HomePage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (_) => const HomePage());
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // user profile
  String gender = 'male';
  int age = 21;
  int weight = 95; // kg
  int height = 184; // cm
  final int caloriesTarget = 1500;

  // BMR and basal tracking
  late final int bmrValue;
  double _basalAccumulated = 0;
  late final double _basalPerInterval;
  Timer? _basalTimer;
  Timer? _midnightTimer;

  // exercise and total burn
  int exerciseBurn = 0;
  int totalBurn = 0;

  @override
  void initState() {
    super.initState();

    // Compute BMR
    bmrValue = calculateBMR(
      gender: gender,
      age: age,
      weight: weight.toDouble(),
      height: height.toDouble(),
    ).toInt();

    // Basal burn per 30-minute interval
    const intervalsPerDay = 48;
    _basalPerInterval = bmrValue / intervalsPerDay;

    // Initialize basal accrued from midnight to now
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final elapsedIntervals = now.difference(startOfDay).inMinutes ~/ 30;
    _basalAccumulated = elapsedIntervals * _basalPerInterval;

    // Compute initial total burn
    _updateTotalBurn();

    // Start half-hourly basal updates
    _basalTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      setState(() {
        _basalAccumulated += _basalPerInterval;
        _updateTotalBurn();
      });
    });

    // Schedule reset at next midnight
    _scheduleMidnightReset();

    // Fetch exercise burn
    _loadCalories();
  }

  void _scheduleMidnightReset() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final untilMidnight = tomorrow.difference(now);

    _midnightTimer = Timer(untilMidnight, () {
      setState(() {
        _basalAccumulated = 0;
        exerciseBurn = 0;
        _updateTotalBurn();
      });
      _scheduleMidnightReset();
    });
  }

  Future<void> _loadCalories() async {
    final result = await HealthService().getTodayCaloriesBurned();
    if (!mounted) return;
    setState(() {
      exerciseBurn = result.toInt();
      _updateTotalBurn();
    });
  }

  void _updateTotalBurn() {
    totalBurn = _basalAccumulated.toInt() + exerciseBurn;
  }

  @override
  void dispose() {
    _basalTimer?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mock intake data
    final String username = 'MadGun';
    final int consumedCalories = 1250;
    final int targetCalories = 2000;

    // Meal data (placeholder)
    final meals = [
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
          child: Image.asset('assets/images/image.png', height: 150),
        ),
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
                      'Hello, $username!',
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
                            current: totalBurn,
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
                              type: meal['type'] as String,
                              time: meal['time'] as String,
                              description: meal['description'] as String,
                              calories: meal['calories'] as int,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 0),
    );
  }
}
