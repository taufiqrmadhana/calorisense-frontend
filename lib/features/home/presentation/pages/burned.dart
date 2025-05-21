import 'package:calorisense/core/theme/pallete.dart';
import 'package:calorisense/features/home/presentation/widgets/daily_stats.dart';
import 'package:flutter/material.dart';
import 'package:calorisense/services/health_service.dart';

class CaloriesBurnedPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const CaloriesBurnedPage());
  const CaloriesBurnedPage({super.key});

  @override
  State<CaloriesBurnedPage> createState() => _CaloriesBurnedPageState();
}

class _CaloriesBurnedPageState extends State<CaloriesBurnedPage> {
  int caloriesOut=0;
  final int caloriesTarget = 1500;


  @override
    void initState() {
    super.initState();
    // print('[initState] caloriesOut = $caloriesOut');
    fetchCalories(); 
    }

  Future<void> fetchCalories() async {
    // print('[fetchCalories] ▶ start');
    final result = await HealthService().getTodayCaloriesBurned();
    // print('[fetchCalories] ✅ got result = $result');
    if (!mounted) {
      // print('[fetchCalories] ⚠️ widget no longer mounted, aborting setState');
      return;
    }
    setState(() {
      caloriesOut = result.toInt();
    });
    // print('[fetchCalories] 🔄 after setState, caloriesOut = $caloriesOut');
  }

  Widget build(BuildContext context) {
    // print('🔥 build(): caloriesOut = $caloriesOut');
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          icon: Icons.directions_run,
                          title: 'Calories Burned',
                          current: caloriesOut,
                          target: caloriesTarget,
                          unit: 'cal',
                          color: AppPalette.mediumorange,
                          backgroundColor: AppPalette.lightorange,
                          onPressed: () {
                            Navigator.push(context, CaloriesBurnedPage.route());
                          },
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

  const ExpandedSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: child);
  }
}
