import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Import RouteObserver dari main.dart (atau tempat Anda mendefinisikannya)
// Sesuaikan path import di bawah ini jika file main.dart Anda ada di lokasi berbeda
// Contoh: import 'package:your_app_name/main.dart';
// Jika main.dart ada di lib/main.dart dan home_page.dart di lib/features/home/presentation/pages/home_page.dart
// maka path-nya mungkin: import '../../../../main.dart';
import '../../../../main.dart'; // <-- PASTIKAN PATH INI BENAR untuk mengakses routeObserver
import 'package:calorisense/main.dart';
import 'package:calorisense/features/chat/presentation/pages/chat_page.dart';
import 'package:calorisense/features/home/presentation/pages/burned.dart';
import 'package:calorisense/features/home/presentation/pages/intake.dart';
import 'package:calorisense/features/home/presentation/widgets/action_button.dart';
import 'package:calorisense/core/common/widgets/bottom_navbar.dart';
import 'package:calorisense/features/home/presentation/widgets/daily_stats.dart';
import 'package:calorisense/core/theme/pallete.dart';


// --- Data Models (tidak berubah) ---
class IntakeResponse {
  final String email;
  final List<DailyIntake> intakes;
  IntakeResponse({required this.email, required this.intakes});
  factory IntakeResponse.fromJson(Map<String, dynamic> json) {
    var intakesList = json['intakes'] as List;
    List<DailyIntake> intakesResult = intakesList.map((i) => DailyIntake.fromJson(i)).toList();
    return IntakeResponse(email: json['email'], intakes: intakesResult);
  }
}
class DailyIntake {
  final String date;
  final int protein;
  final int carbohydrate;
  final int fat;
  final List<String> foods;
  DailyIntake({required this.date, required this.protein, required this.carbohydrate, required this.fat, required this.foods});
  factory DailyIntake.fromJson(Map<String, dynamic> json) {
    var foodsList = json['foods'] as List;
    List<String> foodsResult = foodsList.map((i) => i.toString()).toList();
    return DailyIntake(
      date: json['date']?.toString() ?? DateFormat('yyyy-MM-dd').format(DateTime(1970,1,1)),
      protein: (json['protein'] ?? 0) as int,
      carbohydrate: (json['carbohydrate'] ?? 0) as int,
      fat: (json['fat'] ?? 0) as int,
      foods: foodsResult,
    );
  }
  int get totalCalories => (protein * 4) + (carbohydrate * 4) + (fat * 9);
}

// --- API Service (tidak berubah) ---
class IntakeApiService {
  final String baseUrl = "http://localhost:8000"; // GANTI DENGAN URL BASE API ANDA
  Future<IntakeResponse> getUserIntake(String email) async {
    final Uri url = Uri.parse('$baseUrl/user/intake/$email');
    try {
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        return IntakeResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to load intake data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load intake data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching intake data: $e');
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

// 3. Gunakan RouteAware
class _HomePageState extends State<HomePage> with RouteAware {
  final String username = "MadGun";
  int consumedCalories = 0;
  final int targetCalories = 2000;
  final int caloriesOut = 1000;
  final int caloriesTarget = 1500;

  List<String> todaysFoods = [];
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
      // Subscribe ke routeObserver global yang di-import dari main.dart
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // Unsubscribe dari routeObserver global
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Dipanggil ketika halaman di atas HomePage di-pop, dan HomePage kembali terlihat.
    // Refresh data di sini.
    print("HomePage: Kembali ke halaman ini, me-refresh data...");
    _fetchIntakeData();
  }

  // Opsional: method RouteAware lainnya jika diperlukan
  // @override
  // void didPush() {
  //   // Dipanggil ketika HomePage di-push ke navigator.
  //   // _fetchIntakeData() sudah dipanggil di initState.
  //   print("HomePage: Halaman di-push.");
  // }
  //
  // @override
  // void didPushNext() {
  //   // Dipanggil ketika halaman baru di-push di atas HomePage.
  //   print("HomePage: Halaman baru di-push di atas halaman ini.");
  // }

  Future<void> _fetchIntakeData() async {
    if (!mounted) return; // Cek jika widget masih ada di tree
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final String userEmail = "taufiqaja@gmail.com";
      final intakeResponse = await _apiService.getUserIntake(userEmail);
      
      final String todayDateString = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      DailyIntake? todaysIntakeFromResponse;
      try {
        todaysIntakeFromResponse = intakeResponse.intakes.firstWhere(
          (intake) => intake.date == todayDateString,
        );
      } catch (e) {
        todaysIntakeFromResponse = null; 
      }

      if (!mounted) return; // Cek lagi sebelum setState

      if (todaysIntakeFromResponse != null) {
        final int calculatedCalories = todaysIntakeFromResponse.totalCalories;
        final List<String> foodsForToday = List<String>.from(todaysIntakeFromResponse.foods);
        setState(() {
          consumedCalories = calculatedCalories;
          todaysFoods = foodsForToday;
        });
      } else {
        setState(() {
          consumedCalories = 0;
          todaysFoods = [];
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
      print(e); 
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $_errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 10),
                        ElevatedButton(onPressed: _fetchIntakeData, child: const Text("Retry"))
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
                                      current: consumedCalories,
                                      target: targetCalories,
                                      unit: 'cal',
                                      color: AppPalette.primaryColor,
                                      backgroundColor: AppPalette.lightgreen,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          CaloriesIntakePage.route(),
                                        ); // .then() tidak diperlukan lagi di sini untuk refresh HomePage
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
                                        Navigator.push(context, ChatPage.route()); // .then() tidak diperlukan
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
                                        // Jika CaloriesBurnedPage tidak mengubah data HomePage,
                                        // maka tidak perlu refresh. Jika iya, RouteAware akan handle.
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
                            if (todaysFoods.isEmpty && !_isLoading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Text(
                                    "No meals recorded for today yet.",
                                    style: TextStyle(color: AppPalette.darkSubTextColor, fontSize: 14),
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
                                    elevation: 2,
                                    child: ListTile(
                                      leading: const Icon(Icons.fastfood_outlined, color: AppPalette.primaryColor),
                                      title: Text(foodItem),
                                    ),
                                  );
                                },
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