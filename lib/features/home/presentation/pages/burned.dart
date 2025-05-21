import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/home/presentation/widgets/daily_stats.dart';
import 'package:calorisense/services/health_service.dart';

class CaloriesBurnedPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const CaloriesBurnedPage());
  const CaloriesBurnedPage({super.key});

  @override
  State<CaloriesBurnedPage> createState() => _CaloriesBurnedPageState();
}

class _CaloriesBurnedPageState extends State<CaloriesBurnedPage> {
  int exerciseBurn = 0;
  final int caloriesTarget = 1500;

  // BMR tracking
  String gender = 'male';
  int age = 21;
  int weight = 95;
  int height = 184;
  late final int bmrValue;

  // Basal burn
  double _basalAccumulated = 0;
  late final double _basalPerInterval;
  Timer? _basalTimer;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();

    // Compute BMR once
    bmrValue =
        calculateBMR(
          gender: gender,
          age: age,
          weight: weight.toDouble(),
          height: height.toDouble(),
        ).toInt();

    // Basal per half-hour
    const intervalsPerDay = 48;
    _basalPerInterval = bmrValue / intervalsPerDay;

    // Init basal from midnight
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final elapsed = now.difference(startOfDay).inMinutes ~/ 30;
    _basalAccumulated = elapsed * _basalPerInterval;

    // Periodic basal
    _basalTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      setState(() {
        _basalAccumulated += _basalPerInterval;
      });
    });

    // Reset at midnight
    _scheduleMidnightReset();

    // Fetch exercise
    fetchCalories();
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
      });
      _scheduleMidnightReset();
    });
  }

  Future<void> fetchCalories() async {
    final result = await HealthService().getTodayCaloriesBurned();
    if (!mounted) return;
    setState(() => exerciseBurn = result.toInt());
  }

  @override
  void dispose() {
    _basalTimer?.cancel();
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prepare chart data
    final double basalVal = _basalAccumulated;
    final double exerciseVal = exerciseBurn.toDouble();

    final sections = [
      PieChartSectionData(
        color: AppPalette.gradient1,
        value: basalVal,
        title: '',
        radius: 60,
      ),
      PieChartSectionData(
        color: AppPalette.mediumorange,
        value: exerciseVal,
        title: '',
        radius: 60,
      ),
    ];

    // Legend with colored text
    Widget legend(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, color: color)),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calories Burned',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppPalette.white,
        shape: const Border(
          bottom: BorderSide(width: 1, color: AppPalette.borderColor),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DailyStatsWidget(
              icon: Icons.directions_run,
              title: 'Total Calories Today',
              current: (basalVal + exerciseVal).toInt(),
              target: caloriesTarget,
              unit: 'cal',
              color: AppPalette.mediumorange,
              backgroundColor: AppPalette.lightorange,
              onPressed: () {},
            ),
            const SizedBox(height: 32),
            const Text(
              'Burn Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppPalette.textColor,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 0,
                  startDegreeOffset: -90,
                ),
                swapAnimationDuration: const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeInOut,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                legend(AppPalette.gradient1, 'Basal: ${basalVal.toInt()} cal'),
                const SizedBox(width: 24),
                legend(
                  AppPalette.mediumorange,
                  'Exercise: ${exerciseVal.toInt()} cal',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
