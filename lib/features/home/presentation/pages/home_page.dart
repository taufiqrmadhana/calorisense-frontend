import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:calorisense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:calorisense/core/common/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

import 'package:calorisense/services/health_service.dart';

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
  final String baseUrl = "https://calorisense-be.onrender.com";

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
        throw Exception('Failed to load intake data: ${response.statusCode} & ${response.body}');
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
  // final String username = "MadGun";
  User? _currentUser;
  double consumedCalories = 0.0;
  final int targetCalories = 2000;
  // final int caloriesOut = 1000; <-- ga dipake
  // final int caloriesTarget = 1500; <-- ga dipake

  List<String> todaysFoods = [];
  double _todaysProtein = 0.0;
  double _todaysCarbohydrate = 0.0;
  double _todaysFat = 0.0;

  bool _isLoading = true;
  String? _errorMessage;

  // user profile
  String gender = 'male';
  String birthDateString = '2004-12-08'; // YYYY-MM-DD
  final int age = 0;
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

  final IntakeApiService _apiService = IntakeApiService();

  @override
  void initState() {
    super.initState();
    // Ambil data user dari AppUserCubit saat initState
    final appUserState = context.read<AppUserCubit>().state;
    if (appUserState is AppUserLoggedIn) {
      _currentUser = appUserState.user;
      if (_currentUser != null) {
        _fetchIntakeData(_currentUser!.email); // Panggil dengan email user
      } else {
        // Handle jika _currentUser null meski state AppUserLoggedIn (seharusnya tidak terjadi)
        _handleFetchError("User data not available.");
      }
    } else {
      // Handle jika user tidak login saat HomePage ditampilkan
      // Ini bisa berarti ada masalah di alur navigasi Anda
      _handleFetchError("User not logged in.");
    }

    final hs = HealthService();
    // Compute BMR
    bmrValue =
        hs
            .calculateBMR(
              gender: gender,
              age: hs.calculateAgeFromString(birthDateString),
              weight: weight.toDouble(),
              height: height.toDouble(),
            )
            .toInt();

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

  void _loadInitialData() {
    final appUserState = context.read<AppUserCubit>().state;
    if (appUserState is AppUserLoggedIn) {
      _currentUser = appUserState.user;
      if (_currentUser != null && _currentUser!.email.isNotEmpty) {
        _fetchIntakeData(_currentUser!.email);
      } else {
        _handleFetchError("User email is not available.");
      }
    } else {
      _handleFetchError("User not logged in.");
    }
  }

  void _handleFetchError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
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

    _basalTimer?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Dipanggil ketika kembali ke halaman ini
    final appUserState = context.read<AppUserCubit>().state;
    if (appUserState is AppUserLoggedIn) {
      _currentUser = appUserState.user;
      if (_currentUser != null) {
        _fetchIntakeData(_currentUser!.email);
      } else {
        _handleFetchError("User data not available on navigating back.");
      }
    } else {
      _handleFetchError("User not logged in on navigating back.");
    }
  }

  Future<void> _fetchIntakeData(String userEmail) async {
    // userEmail sekarang menjadi parameter
    if (!mounted) return; // Pemeriksaan mounted di awal
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Email pengguna sekarang didapatkan dari parameter,
      // jadi baris hardcoded dihilangkan.
      // final String userEmail = "taufiqaja@gmail.com"; // <--- HILANGKAN INI

      // Gunakan userEmail dari parameter untuk memanggil API service
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
        // Jika tidak ada data untuk hari ini, biarkan todaysIntakeFromResponse null
        todaysIntakeFromResponse = null;
        print(
          "Info: No intake data found for today ($todayDateString). Error: $e",
        );
      }

      if (!mounted) return; // Periksa lagi sebelum setState

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
        // Jika tidak ada data untuk hari ini, reset nilainya
        setState(() {
          consumedCalories = 0.0;
          todaysFoods = [];
          _todaysProtein = 0.0;
          _todaysCarbohydrate = 0.0;
          _todaysFat = 0.0;
        });
      }
    } catch (e) {
      if (!mounted) return; // Periksa lagi sebelum setState
      print("Error fetching intake data: $e");
      setState(() {
        _errorMessage = e.toString();
        // Reset juga nilai-nilai data jika terjadi error
        consumedCalories = 0.0;
        todaysFoods = [];
        _todaysProtein = 0.0;
        _todaysCarbohydrate = 0.0;
        _todaysFat = 0.0;
      });
    } finally {
      if (!mounted) return; // Periksa lagi sebelum setState
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil state AppUserCubit untuk mendapatkan nama pengguna
    final appUserState = context.watch<AppUserCubit>().state;
    String displayUsername = "User";

    if (appUserState is AppUserLoggedIn) {
      displayUsername = appUserState.user.name;
    }

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
                        onPressed: () {
                          // <--- PERBAIKAN DI SINI
                          if (_currentUser != null &&
                              _currentUser!.email.isNotEmpty) {
                            // Jika _currentUser dan emailnya ada, panggil _fetchIntakeData dengan email tersebut
                            _fetchIntakeData(_currentUser!.email);
                          } else {
                            // Jika _currentUser atau emailnya null, coba load initial data lagi.
                            // _loadInitialData() akan mencoba mengambil user dari AppUserCubit
                            // dan kemudian memanggil _fetchIntakeData jika berhasil.
                            print(
                              "DEBUG: Retry pressed, _currentUser or email is null. Calling _loadInitialData().",
                            );
                            _loadInitialData(); // Pastikan _loadInitialData() sudah ada seperti contoh sebelumnya
                          }
                        },
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
                              "Hello, $displayUsername!",
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
                                    current: totalBurn,
                                    target: caloriesTarget,
                                    unit: 'cal',
                                    color: AppPalette.mediumorange,
                                    backgroundColor: AppPalette.lightorange,
                                    // onPressed: () {
                                    //   Navigator.push(
                                    //     context,
                                    //     CaloriesBurnedPage.route(),
                                    //   );
                                    // },
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
