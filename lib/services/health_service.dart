import 'package:health/health.dart';

class HealthService {
  final HealthFactory _health = HealthFactory();

  /// Fetch total active energy burned in the past 24 hours
  Future<double> getTodayCaloriesBurned() async {
    final types = [HealthDataType.ACTIVE_ENERGY_BURNED];
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 1));

    // Request permission
    final isAuthorized = await _health.requestAuthorization(types);
    if (!isAuthorized) {
      throw Exception('Health permission not granted');
    }

    // Fetch data
    final data = await _health.getHealthDataFromTypes(start, now, types);
    final total = data.fold<double>(0.0, (sum, dp) => sum + (dp.value as double));

    return total;
  }
}
