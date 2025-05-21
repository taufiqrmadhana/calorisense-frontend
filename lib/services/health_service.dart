import 'package:health/health.dart';
import 'dart:io';


class HealthService {
  final HealthFactory _health = HealthFactory();

  final List<HealthDataType> _types = [HealthDataType.ACTIVE_ENERGY_BURNED];

Future<bool> _ensureAuthorization() async {
  if (!Platform.isIOS) {
    // debugPrint("❌ HealthKit not available on this platform.");
    return false;
  }

  final isAuthorized = await _health.requestAuthorization(_types);
//   debugPrint("✅ isAuthorized: $isAuthorized");
  
  if (!isAuthorized) {
    // debugPrint("❌ Health permission not granted");
  }

  return isAuthorized;
}


  /// Total active calories burned over the past 24 hours
Future<double> getTodayCaloriesBurned() async {
  // 1 Request permissions
  final authorized = await _health.requestAuthorization(_types);
//   print('HealthKit authorized? $authorized');

  // 2 Fetch the raw data
  final now   = DateTime.now();
  final start = now.subtract(const Duration(days: 1));
  final data  = await _health.getHealthDataFromTypes(start, now, _types);
//   print('Fetched ${data.length} samples for ACTIVE_ENERGY_BURNED');

  // 3 Sum them up in a double accumulator
  double total = 0.0;
  for (final dp in data) {
    final hv = dp.value;
    if (hv is NumericHealthValue) {
      // numericValue is a num, so .toDouble() is available
      total += hv.numericValue.toDouble();
    } else {
      // if you ever get other HealthValue types, handle them here
    }
  }

//   print('[getTodayCaloriesBurned] ☑️ total = $total kcal');
  return total;
}



  /// Fetch all active energy data points in the last 24 hours
  Future<List<HealthDataPoint>> getTodayCalorieDataPoints() async {
    await _ensureAuthorization();
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 1));
    return await _health.getHealthDataFromTypes(start, now, _types);
  }

  /// Group calories burned by hour (for bar chart)
  Future<Map<int, double>> getCaloriesByHour() async {
    final points = await getTodayCalorieDataPoints();
    final Map<int, double> hourly = {};

    for (var dp in points) {
      int hour = dp.dateFrom.hour;
      hourly[hour] = (hourly[hour] ?? 0) + (dp.value as double);
    }

    return hourly;
  }

  /// Detect high-calorie bursts (e.g., workouts or running)
  Future<List<HealthDataPoint>> getHighCalorieEvents({
    double minKcal = 80.0,
    int minMinutes = 10,
  }) async {
    final points = await getTodayCalorieDataPoints();
    return points.where((dp) {
      final duration = dp.dateTo.difference(dp.dateFrom).inMinutes;
      final value = dp.value as double;
      return value >= minKcal && duration >= minMinutes;
    }).toList();
  }

  /// Get detailed data with burn rate (for analysis/debug/logs)
  Future<List<Map<String, dynamic>>> getDetailedBurnLog() async {
    final points = await getTodayCalorieDataPoints();

    return points.map((dp) {
      final duration = dp.dateTo.difference(dp.dateFrom).inMinutes;
      final kcal = dp.value as double;
      final rate = duration > 0 ? kcal / duration : 0;

      return {
        'from': dp.dateFrom,
        'to': dp.dateTo,
        'value': kcal,
        'source': dp.sourceName,
        'rate_kcal_per_min': rate,
      };
    }).toList();
  }
}
/// Mifflin–St Jeor BMR
double calculateBMR({
  required String gender,
  required int age,
  required double weight,
  required double height,
}) {
  final g = gender.toLowerCase();
  if (g == 'male') {
    return 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    return 10 * weight + 6.25 * height - 5 * age - 161;
  }
}


