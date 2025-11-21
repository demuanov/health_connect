import 'package:health/health.dart';

/// Model representing a summary of health metrics for a specific date
class HealthSummary {
  final DateTime date;
  final int? steps;
  final double? heartRate;
  final double? weight;
  final double? height;
  final double? bmi;
  final Duration? sleepDuration;
  final double? caloriesBurned;
  final double? waterIntake;

  const HealthSummary({
    required this.date,
    this.steps,
    this.heartRate,
    this.weight,
    this.height,
    this.bmi,
    this.sleepDuration,
    this.caloriesBurned,
    this.waterIntake,
  });

  /// Create a health summary from a list of health data points
  factory HealthSummary.fromHealthDataPoints(
    DateTime date,
    List<HealthDataPoint> dataPoints,
  ) {
    int? steps;
    double? heartRate;
    double? weight;
    double? height;
    double? caloriesBurned;
    double? waterIntake;
    Duration? sleepDuration;

    for (final dataPoint in dataPoints) {
      // Filter data points for the specific date
      if (!_isSameDate(dataPoint.dateFrom, date)) continue;

      switch (dataPoint.type) {
        case HealthDataType.STEPS:
          if (dataPoint.value is int) {
            steps = (steps ?? 0) + (dataPoint.value as int);
          }
          break;
        case HealthDataType.HEART_RATE:
          if (dataPoint.value is double) {
            heartRate = dataPoint.value as double;
          }
          break;
        case HealthDataType.WEIGHT:
          if (dataPoint.value is double) {
            weight = dataPoint.value as double;
          }
          break;
        case HealthDataType.HEIGHT:
          if (dataPoint.value is double) {
            height = dataPoint.value as double;
          }
          break;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
        case HealthDataType.BASAL_ENERGY_BURNED:
        case HealthDataType.TOTAL_CALORIES_BURNED:
          if (dataPoint.value is double) {
            caloriesBurned =
                (caloriesBurned ?? 0) + (dataPoint.value as double);
          }
          break;
        case HealthDataType.WATER:
          if (dataPoint.value is double) {
            waterIntake = (waterIntake ?? 0) + (dataPoint.value as double);
          }
          break;
        case HealthDataType.SLEEP_ASLEEP:
        case HealthDataType.SLEEP_SESSION:
          // Calculate sleep duration from start and end times
          final duration = dataPoint.dateTo.difference(dataPoint.dateFrom);
          sleepDuration = (sleepDuration ?? Duration.zero) + duration;
          break;
        default:
          break;
      }
    }

    // Calculate BMI if both weight and height are available
    double? bmi;
    if (weight != null && height != null && height > 0) {
      bmi = weight / (height * height);
    }

    return HealthSummary(
      date: date,
      steps: steps,
      heartRate: heartRate,
      weight: weight,
      height: height,
      bmi: bmi,
      sleepDuration: sleepDuration,
      caloriesBurned: caloriesBurned,
      waterIntake: waterIntake,
    );
  }

  static bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if this summary has any data
  bool get hasData {
    return steps != null ||
        heartRate != null ||
        weight != null ||
        height != null ||
        bmi != null ||
        sleepDuration != null ||
        caloriesBurned != null ||
        waterIntake != null;
  }

  /// Get a fitness score based on available metrics (0-100)
  double get fitnessScore {
    double score = 0;
    int metrics = 0;

    // Steps score (0-25 points)
    if (steps != null) {
      metrics++;
      if (steps! >= 10000) {
        score += 25;
      } else if (steps! >= 5000) {
        score += 15;
      } else if (steps! >= 2500) {
        score += 10;
      } else if (steps! > 0) {
        score += 5;
      }
    }

    // Heart rate score (0-25 points) - assumes resting HR between 60-100 is good
    if (heartRate != null) {
      metrics++;
      if (heartRate! >= 60 && heartRate! <= 100) {
        score += 25;
      } else if (heartRate! >= 50 && heartRate! <= 110) {
        score += 15;
      } else {
        score += 5;
      }
    }

    // Sleep score (0-25 points)
    if (sleepDuration != null) {
      metrics++;
      final hours = sleepDuration!.inHours;
      if (hours >= 7 && hours <= 9) {
        score += 25;
      } else if (hours >= 6 && hours <= 10) {
        score += 15;
      } else if (hours >= 4) {
        score += 10;
      } else {
        score += 5;
      }
    }

    // BMI score (0-25 points)
    if (bmi != null) {
      metrics++;
      if (bmi! >= 18.5 && bmi! < 25) {
        score += 25;
      } else if (bmi! >= 17 && bmi! < 30) {
        score += 15;
      } else {
        score += 5;
      }
    }

    return metrics > 0 ? score : 0;
  }

  @override
  String toString() {
    return 'HealthSummary(date: $date, steps: $steps, heartRate: $heartRate, '
        'weight: $weight, height: $height, bmi: $bmi, '
        'sleepDuration: $sleepDuration, caloriesBurned: $caloriesBurned, '
        'waterIntake: $waterIntake)';
  }
}
