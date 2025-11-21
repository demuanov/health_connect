import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'dart:developer' as developer;
import '../widgets/health_card_widget.dart';

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
    developer.log(
      '=== Starting health data fetch process ===',
      name: 'HealthConnect',
    );

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

      developer.log(
        'Step 1: Defined health data types: ${types.map((t) => t.toString()).join(', ')}',
        name: 'HealthConnect',
      );

      // Request permissions with better error handling - let health plugin handle all permissions
      developer.log(
        'Step 2: Requesting health authorization (including Android permissions)',
        name: 'HealthConnect',
      );
      bool requested;
      try {
        requested = await Health().requestAuthorization(types);
        developer.log(
          'Health authorization request result: $requested',
          name: 'HealthConnect',
        );
      } catch (e) {
        developer.log(
          'Health authorization request failed: $e',
          name: 'HealthConnect',
          error: e,
        );
        setState(() {
          _errorMessage =
              'Permission request failed: ${e.toString()}\n\nPlease ensure:\n1. Physical activity permission is enabled\n2. Body sensors permission is granted\n3. Health app is installed and configured';
          _isLoading = false;
        });
        return;
      }

      if (!requested) {
        developer.log(
          'Health authorization was not granted',
          name: 'HealthConnect',
        );
        setState(() {
          _errorMessage =
              'Health data access permission was denied.\n\nTo enable:\n1. Go to Settings > Apps > Health Connect\n2. Grant necessary permissions\n3. Restart the app';
          _isLoading = false;
        });
        return;
      }

      developer.log(
        'Step 3: Authorization granted, fetching health data',
        name: 'HealthConnect',
      );

      // Fetch steps data for today
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day);

      try {
        developer.log(
          'Step 4a: Fetching steps data from $startOfDay to $now',
          name: 'HealthConnect',
        );
        int? steps = await Health().getTotalStepsInInterval(startOfDay, now);
        developer.log('Steps data result: $steps', name: 'HealthConnect');
        _steps = steps;
      } catch (e) {
        developer.log(
          'Steps data fetch failed: $e',
          name: 'HealthConnect',
          error: e,
        );
        _steps = null;
      }

      // Fetch heart rate data from the last hour
      DateTime oneHourAgo = now.subtract(const Duration(hours: 1));

      try {
        developer.log(
          'Step 4b: Fetching heart rate data from $oneHourAgo to $now',
          name: 'HealthConnect',
        );
        List<HealthDataPoint> heartRateData = await Health()
            .getHealthDataFromTypes(
              types: [HealthDataType.HEART_RATE],
              startTime: oneHourAgo,
              endTime: now,
            );

        developer.log(
          'Heart rate data points count: ${heartRateData.length}',
          name: 'HealthConnect',
        );

        if (heartRateData.isNotEmpty) {
          // Get the most recent heart rate reading
          heartRateData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
          var latestReading = heartRateData.first;
          _heartRate = double.tryParse(latestReading.value.toString());
          developer.log(
            'Latest heart rate: $_heartRate BPM from ${latestReading.dateTo}',
            name: 'HealthConnect',
          );
        } else {
          developer.log('No heart rate data available', name: 'HealthConnect');
          _heartRate = null;
        }
      } catch (e) {
        developer.log(
          'Heart rate data fetch failed: $e',
          name: 'HealthConnect',
          error: e,
        );
        _heartRate = null;
      }

      developer.log(
        'Step 5: Data fetch completed successfully',
        name: 'HealthConnect',
      );
    } catch (e) {
      developer.log(
        'Unexpected error in _fetchHealthData: $e',
        name: 'HealthConnect',
        error: e,
      );
      setState(() {
        _errorMessage =
            'An unexpected error occurred: ${e.toString()}\n\nPlease check your device permissions and try again.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Data'),
        backgroundColor: Colors.blue.shade50,
        elevation: 0,
        foregroundColor: Colors.blue.shade800,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading health data...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
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
                      HealthCardWidget(
                        title: 'Steps Today',
                        value: _steps?.toString() ?? 'No data',
                        icon: Icons.directions_walk,
                        color: Colors.blue,
                        subtitle: 'Total steps for today',
                      ),
                      const SizedBox(height: 16),
                      HealthCardWidget(
                        title: 'Heart Rate',
                        value: _heartRate != null
                            ? '${_heartRate!.toStringAsFixed(0)} BPM'
                            : 'No data',
                        icon: Icons.favorite,
                        color: Colors.red,
                        subtitle: 'Most recent reading',
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
