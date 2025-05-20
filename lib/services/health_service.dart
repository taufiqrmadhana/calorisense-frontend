import 'package:health/health.dart';

class HealthService {
  final HealthFactory _health = HealthFactory();

  final List<HealthDataType> _types = [HealthDataType.ACTIVE_ENERGY_BURNED];

  Future<bool> _ensureAuthorization() async {
    final isAuthorized = await _health.requestAuthorization(_types);
    if (!isAuthorized) {
      throw Exception('Health permission not granted');
    }
    return true;
  }

  /// Total active calories burned over the past 24 hours
  Future<double> getTodayCaloriesBurned() async {
    await _ensureAuthorization();
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(start, now, _types);
    return data.fold(0.0, (sum, dp) => sum + (dp.value as double));
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
