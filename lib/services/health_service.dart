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
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 1));
    final data = await _health.getHealthDataFromTypes(start, now, _types);
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

  int calculateAgeFromString(String birthDateString) {
    final birthDate = DateTime.parse(birthDateString); // parses YYYY-MM-DD
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
