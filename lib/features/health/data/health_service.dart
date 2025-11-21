import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/health_data_types.dart';

/// Service class for managing health data operations
/// Provides a clean interface for health data access and management
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  /// Global Health plugin instance
  final Health _health = Health();

  /// Get the health plugin instance
  Health get health => _health;

  /// List of recording methods to filter
  List<RecordingMethod> recordingMethodsToFilter = [];

  /// All types available depending on platform (iOS or Android)
  List<HealthDataType> get supportedTypes => (Platform.isAndroid)
      ? HealthDataTypes.android
      : (Platform.isIOS)
      ? HealthDataTypes.ios
      : HealthDataTypes.common;

  /// Initialize the health service
  Future<void> initialize() async {
    // Configure the health plugin before use and check the Health Connect status
    _health.configure();
    if (Platform.isAndroid) {
      await _health.getHealthConnectSdkStatus();
    }
  }

  /// Install Google Health Connect on Android devices
  Future<void> installHealthConnect() async {
    if (Platform.isAndroid) {
      await _health.installHealthConnect();
    }
  }

  /// Request necessary permissions for health data access
  Future<bool> requestPermissions() async {
    // Request activity recognition and location permissions first
    await Permission.activityRecognition.request();
    await Permission.location.request();

    // Define permissions for each health data type
    final permissions = supportedTypes
        .map(
          (type) =>
              [
                HealthDataType.ELECTROCARDIOGRAM,
                HealthDataType.HIGH_HEART_RATE_EVENT,
                HealthDataType.LOW_HEART_RATE_EVENT,
                HealthDataType.IRREGULAR_HEART_RATE_EVENT,
                HealthDataType.EXERCISE_TIME,
              ].contains(type)
              ? HealthDataAccess.READ
              : HealthDataAccess.READ_WRITE,
        )
        .toList();

    // Check if we already have permissions
    bool? hasPermissions = await _health.hasPermissions(
      supportedTypes,
      permissions: permissions,
    );

    // Always request permissions as hasPermissions may not disclose WRITE access
    hasPermissions = false;

    bool authorized = false;
    if (!hasPermissions) {
      try {
        authorized = await _health.requestAuthorization(
          supportedTypes,
          permissions: permissions,
        );

        // Request additional permissions for iOS
        if (Platform.isIOS) {
          await _health.requestHealthDataHistoryAuthorization();
          await _health.requestHealthDataInBackgroundAuthorization();
        }
      } catch (error) {
        debugPrint("Exception in requestPermissions: $error");
        return false;
      }
    }

    return authorized;
  }

  /// Get Health Connect SDK status (Android only)
  Future<HealthConnectSdkStatus?> getHealthConnectSdkStatus() async {
    if (Platform.isAndroid) {
      return await _health.getHealthConnectSdkStatus();
    }
    return null;
  }

  /// Fetch health data for specified types within a time range
  Future<List<HealthDataPoint>> fetchHealthData({
    required DateTime startTime,
    required DateTime endTime,
    List<HealthDataType>? types,
  }) async {
    try {
      final healthData = await _health.getHealthDataFromTypes(
        types: types ?? supportedTypes,
        startTime: startTime,
        endTime: endTime,
        recordingMethodsToFilter: recordingMethodsToFilter,
      );

      // Remove duplicates and sort by date
      final cleanedData = _health.removeDuplicates(healthData);
      cleanedData.sort((a, b) => b.dateTo.compareTo(a.dateTo));

      return cleanedData;
    } catch (error) {
      debugPrint("Exception in fetchHealthData: $error");
      return [];
    }
  }

  /// Fetch a single health data point by UUID
  Future<HealthDataPoint?> fetchHealthDataByUUID({
    required String uuid,
    required HealthDataType type,
  }) async {
    try {
      return await _health.getHealthDataByUUID(uuid: uuid, type: type);
    } catch (error) {
      debugPrint("Exception in fetchHealthDataByUUID: $error");
      return null;
    }
  }

  /// Get total steps in a specific interval
  Future<int?> getTotalSteps({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // Check permissions first
    bool stepsPermission =
        await _health.hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!stepsPermission) {
      stepsPermission = await _health.requestAuthorization([
        HealthDataType.STEPS,
      ]);
    }

    if (stepsPermission) {
      try {
        return await _health.getTotalStepsInInterval(
          startTime,
          endTime,
          includeManualEntry: !recordingMethodsToFilter.contains(
            RecordingMethod.manual,
          ),
        );
      } catch (error) {
        debugPrint("Exception in getTotalSteps: $error");
      }
    }
    return null;
  }

  /// Get interval-based health data
  Future<List<HealthDataPoint>> getIntervalBasedData({
    required DateTime startTime,
    required DateTime endTime,
    List<HealthDataType>? types,
    int intervalSeconds = 86400, // 1 day by default
  }) async {
    try {
      return await _health.getHealthIntervalDataFromTypes(
        startDate: startTime,
        endDate: endTime,
        types: types ?? [HealthDataType.BLOOD_OXYGEN, HealthDataType.STEPS],
        interval: intervalSeconds,
      );
    } catch (error) {
      debugPrint("Exception in getIntervalBasedData: $error");
      return [];
    }
  }

  /// Add sample workout sessions for the past week
  Future<bool> addSampleData() async {
    final now = DateTime.now();
    bool success = true;
    // All available workout activity types
    final activityTypes = <HealthWorkoutActivityType>[
      ...HealthWorkoutActivityType.values,
    ];

    try {
      for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
        final activity = activityTypes[dayOffset % activityTypes.length];
        final workoutEnd = now.subtract(Duration(days: dayOffset));
        final workoutStart = workoutEnd.subtract(
          Duration(minutes: 30 + (dayOffset * 5)),
        );

        // Scale burned energy and distance a bit per day so charts look natural
        final totalEnergy = 180 + dayOffset * 20; // kcal
        final totalDistance = 2500 + dayOffset * 150; // meters

        success &= await _health.writeWorkoutData(
          activityType: activity,
          title: "Sample ${activity.name.toLowerCase()} session",
          start: workoutStart,
          end: workoutEnd,
          totalEnergyBurned: totalEnergy,
          totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
          totalDistance: totalDistance,
          totalDistanceUnit: HealthDataUnit.METER,
        );
      }
    } catch (error) {
      debugPrint("Exception in addSampleData: $error");
      return false;
    }

    return success;
  }

  /// Delete health data for specified types within a time range
  Future<bool> deleteHealthData({
    required DateTime startTime,
    required DateTime endTime,
    List<HealthDataType>? types,
  }) async {
    bool success = true;
    final typesToDelete = types ?? supportedTypes;

    try {
      for (HealthDataType type in typesToDelete) {
        success &= await _health.delete(
          type: type,
          startTime: startTime,
          endTime: endTime,
        );
      }
    } catch (error) {
      debugPrint("Exception in deleteHealthData: $error");
      return false;
    }

    return success;
  }

  /// Delete health data by UUID
  Future<bool> deleteHealthDataByUUID({
    required String uuid,
    required HealthDataType type,
  }) async {
    try {
      return await _health.deleteByUUID(type: type, uuid: uuid);
    } catch (error) {
      debugPrint("Exception in deleteHealthDataByUUID: $error");
      return false;
    }
  }

  /// Revoke health data permissions (Android only)
  Future<bool> revokePermissions() async {
    try {
      await _health.revokePermissions();
      return true;
    } catch (error) {
      debugPrint("Exception in revokePermissions: $error");
      return false;
    }
  }

  /// Check if specific permissions are granted
  Future<bool> hasPermissions(List<HealthDataType> types) async {
    try {
      return await _health.hasPermissions(types) ?? false;
    } catch (error) {
      debugPrint("Exception in hasPermissions: $error");
      return false;
    }
  }
}
