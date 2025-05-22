import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../main.dart';

import 'package:calorisense/features/chat/presentation/pages/chat_page.dart';
import 'package:calorisense/features/home/presentation/pages/burned.dart';
import 'package:calorisense/features/home/presentation/pages/intake.dart';
import 'package:calorisense/features/home/presentation/widgets/action_button.dart';
import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/features/home/presentation/widgets/daily_stats.dart';
import 'package:calorisense/core/theme/pallete.dart';

class IntakeResponse {
  final String email;
  final List<DailyIntake> intakes;

  IntakeResponse({required this.email, required this.intakes});

  factory IntakeResponse.fromJson(Map<String, dynamic> json) {
    var intakesList = json['intakes'] as List;
    List<DailyIntake> intakesResult =
        intakesList.map((i) => DailyIntake.fromJson(i)).toList();
    return IntakeResponse(email: json['email'], intakes: intakesResult);
  }
}

class DailyIntake {
  final String date;
  final double protein;
  final double carbohydrate;
  final double fat;
  final List<String> foods;

  DailyIntake({
    required this.date,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.foods,
  });

  factory DailyIntake.fromJson(Map<String, dynamic> json) {
    var foodsList = json['foods'] as List?;
    List<String> foodsResult =
        foodsList?.map((i) => i.toString()).toList() ?? [];

    return DailyIntake(
      date:
          json['date']?.toString() ??
          DateFormat('yyyy-MM-dd').format(DateTime(1970, 1, 1)),
      protein: (json['protein'] as num? ?? 0.0).toDouble(),
      carbohydrate: (json['carbohydrate'] as num? ?? 0.0).toDouble(),
      fat: (json['fat'] as num? ?? 0.0).toDouble(),
      foods: foodsResult,
    );
  }

  double get totalCalories =>
      (protein * 4.0) + (carbohydrate * 4.0) + (fat * 9.0);
}

class IntakeApiService {
  final String baseUrl = "http://0.0.0.0:8000";

  Future<IntakeResponse> getUserIntake(String email) async {
    final Uri url = Uri.parse('$baseUrl/user/intake/$email');
    try {
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return IntakeResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load intake data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch intake data: $e');
    }
  }
}

class HomePage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const HomePage());
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final String username = "MadGun";
  double consumedCalories = 0.0;
  final int targetCalories = 2000;
  final int caloriesOut = 1000;
  final int caloriesTarget = 1500;

  List<String> todaysFoods = [];
  double _todaysProtein = 0.0;
  double _todaysCarbohydrate = 0.0;
  double _todaysFat = 0.0;

  bool _isLoading = true;
  String? _errorMessage;

  final IntakeApiService _apiService = IntakeApiService();

  @override
  void initState() {
    super.initState();
    _fetchIntakeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _fetchIntakeData();
  }

  Future<void> _fetchIntakeData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final String userEmail = "taufiqaja@gmail.com";
      final intakeResponse = await _apiService.getUserIntake(userEmail);

      final String todayDateString = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now());

      DailyIntake? todaysIntakeFromResponse;
      try {
        todaysIntakeFromResponse = intakeResponse.intakes.firstWhere(
          (intake) => intake.date == todayDateString,
        );
      } catch (e) {
        todaysIntakeFromResponse = null;
      }

      if (!mounted) return;

      if (todaysIntakeFromResponse != null) {
        final DailyIntake currentDayData = todaysIntakeFromResponse;

        final double calculatedCalories = currentDayData.totalCalories;
        final List<String> foodsForToday = List<String>.from(
          currentDayData.foods,
        );

        setState(() {
          consumedCalories = calculatedCalories;
          todaysFoods = foodsForToday;
          _todaysProtein = currentDayData.protein;
          _todaysCarbohydrate = currentDayData.carbohydrate;
          _todaysFat = currentDayData.fat;
        });
      } else {
        setState(() {
          consumedCalories = 0.0;
          todaysFoods = [];
          _todaysProtein = 0.0;
          _todaysCarbohydrate = 0.0;
          _todaysFat = 0.0;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchIntakeData,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
              : SingleChildScrollView(
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
                                    current: consumedCalories.round(),
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
                          const SizedBox(height: 8),
                          if (!_isLoading &&
                              (consumedCalories > 0 ||
                                  todaysFoods.isNotEmpty ||
                                  _todaysProtein > 0 ||
                                  _todaysCarbohydrate > 0 ||
                                  _todaysFat > 0))
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Protein: ${_todaysProtein.toStringAsFixed(1)}g",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppPalette.darkSubTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Total Carbohydrate: ${_todaysCarbohydrate.toStringAsFixed(1)}g",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppPalette.darkSubTextColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Total Fat: ${_todaysFat.toStringAsFixed(1)}g",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppPalette.darkSubTextColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          if (todaysFoods.isEmpty &&
                              !_isLoading &&
                              consumedCalories == 0 &&
                              _todaysProtein == 0 &&
                              _todaysCarbohydrate == 0 &&
                              _todaysFat == 0)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  "No meals recorded for today yet.",
                                  style: TextStyle(
                                    color: AppPalette.darkSubTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else if (todaysFoods.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: todaysFoods.length,
                              itemBuilder: (context, index) {
                                final foodItem = todaysFoods[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  elevation: 1,
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.food_bank_outlined,
                                      color: AppPalette.primaryColor,
                                      size: 20,
                                    ),
                                    title: Text(
                                      foodItem,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    dense: true,
                                  ),
                                );
                              },
                            )
                          else if (!_isLoading &&
                              (consumedCalories > 0 ||
                                  _todaysProtein > 0 ||
                                  _todaysCarbohydrate > 0 ||
                                  _todaysFat > 0) &&
                              todaysFoods.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 0, bottom: 16.0),
                              child: Text(
                                "No specific food items listed for today's intake.",
                                style: TextStyle(
                                  color: AppPalette.darkSubTextColor,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      bottomNavigationBar: const BottomNavBarWidget(currentIndex: 0),
    );
  }
}
