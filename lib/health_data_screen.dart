import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:developer' as developer;

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  int? _steps;
  double? _heartRate;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    developer.log('HealthDataScreen initialized', name: 'HealthConnect');
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    developer.log('=== Starting health data fetch process ===', name: 'HealthConnect');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Define the types of health data we want to access
      List<HealthDataType> types = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
      ];

      developer.log('Step 1: Defined health data types: ${types.map((t) => t.toString()).join(', ')}', name: 'HealthConnect');

      // Request permissions with better error handling - let health plugin handle all permissions
      developer.log('Step 2: Requesting health authorization (including Android permissions)', name: 'HealthConnect');
      bool requested;
      try {
        requested = await Health().requestAuthorization(types);
        developer.log('Health authorization request result: $requested', name: 'HealthConnect');
      } catch (e) {
        developer.log('Health authorization request failed: $e', name: 'HealthConnect', error: e);
        setState(() {
          _errorMessage = 'Permission request failed: ${e.toString()}\n\nPlease ensure:\n1. Physical activity permission is enabled\n2. Body sensors permission is granted\n3. Health app is installed and configured';
          _isLoading = false;
        });
        return;
      }

      if (!requested) {
        developer.log('Health authorization was not granted', name: 'HealthConnect');
        setState(() {
          _errorMessage = 'Health authorization not granted. Please enable health permissions in your device settings.\n\nGo to Settings > Apps > Health Connect > Permissions';
          _isLoading = false;
        });
        return;
      }

      // Check if permissions are granted
      developer.log('Step 3: Checking if permissions are granted', name: 'HealthConnect');
      bool? hasPermissions;
      try {
        hasPermissions = await Health().hasPermissions(types);
        developer.log('Has permissions check result: $hasPermissions', name: 'HealthConnect');
      } catch (e) {
        developer.log('Permission check failed: $e', name: 'HealthConnect', error: e);
        setState(() {
          _errorMessage = 'Permission check failed: ${e.toString()}';
          _isLoading = false;
        });
        return;
      }

      if (hasPermissions != true) {
        developer.log('Permissions not properly granted', name: 'HealthConnect');
        setState(() {
          _errorMessage = 'Health permissions not granted. Please check your device settings and ensure all health permissions are enabled.';
          _isLoading = false;
        });
        return;
      }

      // Fetch data for today
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);
      developer.log('Step 4: Fetching data from $startOfDay to $now', name: 'HealthConnect');

      // Fetch steps
      developer.log('Step 4a: Fetching steps data', name: 'HealthConnect');
      List<HealthDataPoint> stepsData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );
      developer.log('Retrieved ${stepsData.length} step data points', name: 'HealthConnect');

      // Calculate total steps for today
      int totalSteps = 0;
      for (var dataPoint in stepsData) {
        if (dataPoint.value is NumericHealthValue) {
          int stepValue = (dataPoint.value as NumericHealthValue).numericValue.toInt();
          totalSteps += stepValue;
          developer.log('Step data point: $stepValue steps at ${dataPoint.dateFrom} - ${dataPoint.dateTo}', name: 'HealthConnect');
        }
      }
      developer.log('Total steps calculated: $totalSteps', name: 'HealthConnect');

      // Fetch heart rate (last 24 hours)
      DateTime yesterday = now.subtract(const Duration(hours: 24));
      developer.log('Step 4b: Fetching heart rate data from $yesterday to $now', name: 'HealthConnect');
      List<HealthDataPoint> heartRateData = await Health().getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: yesterday,
        endTime: now,
      );
      developer.log('Retrieved ${heartRateData.length} heart rate data points', name: 'HealthConnect');

      // Get the most recent heart rate reading
      double? latestHeartRate;
      if (heartRateData.isNotEmpty) {
        // Sort by date to get the most recent
        heartRateData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        var latestReading = heartRateData.first;
        if (latestReading.value is NumericHealthValue) {
          latestHeartRate = (latestReading.value as NumericHealthValue).numericValue.toDouble();
          developer.log('Latest heart rate: $latestHeartRate BPM at ${latestReading.dateTo}', name: 'HealthConnect');
        }

        // Log all heart rate readings for debugging
        for (var i = 0; i < heartRateData.length && i < 5; i++) {
          var dataPoint = heartRateData[i];
          if (dataPoint.value is NumericHealthValue) {
            double hr = (dataPoint.value as NumericHealthValue).numericValue.toDouble();
            developer.log('Heart rate data point ${i + 1}: $hr BPM at ${dataPoint.dateTo}', name: 'HealthConnect');
          }
        }
      } else {
        developer.log('No heart rate data found', name: 'HealthConnect');
      }

      developer.log('Step 5: Updating UI with fetched data', name: 'HealthConnect');
      setState(() {
        _steps = totalSteps;
        _heartRate = latestHeartRate;
        _isLoading = false;
      });

      developer.log('=== Health data fetch completed successfully ===', name: 'HealthConnect');
      developer.log('Final results - Steps: $totalSteps, Heart Rate: $latestHeartRate', name: 'HealthConnect');
    } catch (e) {
      developer.log('=== Health data fetch failed with error ===', name: 'HealthConnect', error: e);
      setState(() {
        _errorMessage = 'Error fetching health data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchHealthData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchHealthData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildHealthCard(
                            title: 'Steps Today',
                            value: _steps?.toString() ?? 'No data',
                            icon: Icons.directions_walk,
                            color: Colors.blue,
                            subtitle: 'Total steps for today',
                          ),
                          const SizedBox(height: 16),
                          _buildHealthCard(
                            title: 'Heart Rate',
                            value: _heartRate != null
                                ? '${_heartRate!.toStringAsFixed(0)} BPM'
                                : 'No data',
                            icon: Icons.favorite,
                            color: Colors.red,
                            subtitle: 'Latest reading',
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Pull to refresh data',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildHealthCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
