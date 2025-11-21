import 'package:health/health.dart';

/// Utility functions for health data operations
class HealthUtils {
  /// Format health data value with appropriate units
  static String formatHealthValue(HealthDataPoint healthDataPoint) {
    final value = healthDataPoint.value;
    final unit = healthDataPoint.unit;

    return '$value ${unit.name}';
  }

  /// Get a user-friendly name for health data type
  static String getHealthDataTypeName(HealthDataType type) {
    return type.name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// Check if a health data type is related to fitness/activity
  static bool isFitnessType(HealthDataType type) {
    const fitnessTypes = [
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_WALKING_RUNNING,
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.BASAL_ENERGY_BURNED,
      HealthDataType.FLIGHTS_CLIMBED,
      HealthDataType.WORKOUT,
      HealthDataType.EXERCISE_TIME,
    ];
    return fitnessTypes.contains(type);
  }

  /// Check if a health data type is related to vital signs
  static bool isVitalSignType(HealthDataType type) {
    const vitalSignTypes = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      HealthDataType.BLOOD_OXYGEN,
      HealthDataType.RESPIRATORY_RATE,
      HealthDataType.BODY_TEMPERATURE,
    ];
    return vitalSignTypes.contains(type);
  }

  /// Check if a health data type is related to body measurements
  static bool isBodyMeasurementType(HealthDataType type) {
    const bodyMeasurementTypes = [
      HealthDataType.HEIGHT,
      HealthDataType.WEIGHT,
      HealthDataType.BODY_MASS_INDEX,
      HealthDataType.BODY_FAT_PERCENTAGE,
      HealthDataType.LEAN_BODY_MASS,
      HealthDataType.WAIST_CIRCUMFERENCE,
    ];
    return bodyMeasurementTypes.contains(type);
  }

  /// Check if a health data type is related to sleep
  static bool isSleepType(HealthDataType type) {
    const sleepTypes = [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_AWAKE_IN_BED,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_OUT_OF_BED,
      HealthDataType.SLEEP_UNKNOWN,
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_IN_BED,
    ];
    return sleepTypes.contains(type);
  }

  /// Get category name for a health data type
  static String getHealthDataCategory(HealthDataType type) {
    if (isFitnessType(type)) return 'Fitness & Activity';
    if (isVitalSignType(type)) return 'Vital Signs';
    if (isBodyMeasurementType(type)) return 'Body Measurements';
    if (isSleepType(type)) return 'Sleep';
    return 'Other';
  }

  /// Format date time for display
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format date for display (date only)
  static String formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  /// Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Calculate BMI from weight and height
  static double? calculateBMI(double? weightKg, double? heightM) {
    if (weightKg == null || heightM == null || heightM == 0) return null;
    return weightKg / (heightM * heightM);
  }

  /// Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
