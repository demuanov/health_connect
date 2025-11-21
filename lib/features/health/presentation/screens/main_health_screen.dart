import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import '../../../../core/enums/app_state.dart';
import '../../data/health_service.dart';
import '../widgets/health_data_list_widget.dart';
import '../widgets/health_detail_bottom_sheet.dart';

/// Main screen for health data management and display
class MainHealthScreen extends StatefulWidget {
  const MainHealthScreen({super.key});

  @override
  State<MainHealthScreen> createState() => _MainHealthScreenState();
}

class _MainHealthScreenState extends State<MainHealthScreen> {
  final HealthService _healthService = HealthService();

  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.dataNotFetched;
  int _nofSteps = 0;
  Widget _contentHealthConnectStatus = const Text(
    'No status, click getHealthConnectSdkStatus to get the status.',
  );

  @override
  void initState() {
    super.initState();
    _healthService.initialize();
  }

  /// Install Google Health Connect
  Future<void> _installHealthConnect() async {
    await _healthService.installHealthConnect();
  }

  /// Authorize health data access
  Future<void> _authorize() async {
    final authorized = await _healthService.requestPermissions();
    setState(() {
      _state = authorized ? AppState.authorized : AppState.authNotGranted;
    });
  }

  /// Get Health Connect SDK status
  Future<void> _getHealthConnectSdkStatus() async {
    final status = await _healthService.getHealthConnectSdkStatus();
    setState(() {
      _contentHealthConnectStatus = Text(
        'Health Connect Status: ${status?.name.toUpperCase() ?? 'UNKNOWN'}',
      );
      _state = AppState.healthConnectStatus;
    });
  }

  /// Fetch health data
  Future<void> _fetchData() async {
    setState(() => _state = AppState.fetchingData);

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    final healthData = await _healthService.fetchHealthData(
      startTime: yesterday,
      endTime: now,
    );

    setState(() {
      _healthDataList = healthData.length > 100
          ? healthData.sublist(0, 100)
          : healthData;
      _state = _healthDataList.isEmpty ? AppState.noData : AppState.dataReady;
    });
  }

  /// Add sample health data
  Future<void> _addData() async {
    final success = await _healthService.addSampleData();
    setState(() {
      _state = success ? AppState.dataAdded : AppState.dataNotAdded;
    });
  }

  /// Delete health data
  Future<void> _deleteData() async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));

    final success = await _healthService.deleteHealthData(
      startTime: yesterday,
      endTime: now,
    );

    setState(() {
      _state = success ? AppState.dataDeleted : AppState.dataNotDeleted;
    });
  }

  /// Fetch step data
  Future<void> _fetchStepData() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    final steps = await _healthService.getTotalSteps(
      startTime: midnight,
      endTime: now,
    );

    setState(() {
      _nofSteps = steps ?? 0;
      _state = steps == null ? AppState.noData : AppState.stepsReady;
    });
  }

  /// Revoke permissions
  Future<void> _revokeAccess() async {
    setState(() => _state = AppState.permissionsRevoking);

    final success = await _healthService.revokePermissions();

    setState(() {
      _state = success
          ? AppState.permissionsRevoked
          : AppState.permissionsNotRevoked;
    });
  }

  /// Get interval-based data
  Future<void> _getIntervalBasedData() async {
    final startDate = DateTime.now().subtract(const Duration(days: 7));
    final endDate = DateTime.now();

    final healthDataResponse = await _healthService.getIntervalBasedData(
      startTime: startDate,
      endTime: endDate,
    );

    setState(() {
      _healthDataList = healthDataResponse.length > 100
          ? healthDataResponse.sublist(0, 100)
          : healthDataResponse;
      _state = _healthDataList.isEmpty ? AppState.noData : AppState.dataReady;
    });
  }

  /// Display health data detail bottom sheet
  void _openDetailBottomSheet(
    BuildContext context,
    HealthDataPoint? healthPoint,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) =>
          HealthDetailBottomSheet(healthPoint: healthPoint),
    );
  }

  /// Get content based on current state
  Widget get _content {
    switch (_state) {
      case AppState.dataReady:
        return HealthDataListWidget(
          healthDataList: _healthDataList,
          onItemTap: (healthPoint) =>
              _openDetailBottomSheet(context, healthPoint),
        );
      case AppState.dataNotFetched:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Press 'Auth' to get permissions to access health data."),
            Text("Press 'Fetch Data' to get health data."),
            Text("Press 'Add Data' to add some random health data."),
            Text("Press 'Delete Data' to remove some random health data."),
          ],
        );
      case AppState.fetchingData:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching health data...'),
          ],
        );
      case AppState.noData:
        return const Text('No Data to show');
      case AppState.authorized:
        return const Text('Authorization granted!');
      case AppState.authNotGranted:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Authorization not given.'),
            Text(
              'For Google Health Connect please check if you have added the right permissions and services to the manifest file.',
            ),
            Text('For Apple Health check your permissions in Apple Health.'),
          ],
        );
      case AppState.dataAdded:
        return const Text('Data points inserted successfully.');
      case AppState.dataDeleted:
        return const Text('Data points deleted successfully.');
      case AppState.dataNotAdded:
        return const Text(
          'Failed to add data.\nDo you have permissions to add data?',
        );
      case AppState.dataNotDeleted:
        return const Text('Failed to delete data');
      case AppState.stepsReady:
        return Text('Total number of steps: $_nofSteps.');
      case AppState.healthConnectStatus:
        return _contentHealthConnectStatus;
      case AppState.permissionsRevoking:
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Revoking permissions...'),
          ],
        );
      case AppState.permissionsRevoked:
        return const Text('Permissions revoked successfully.');
      case AppState.permissionsNotRevoked:
        return const Text('Failed to revoke permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Connect Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Health Example'),
          backgroundColor: Colors.blue.shade50,
          elevation: 0,
          foregroundColor: Colors.blue.shade800,
        ),
        body: Column(
          children: [
            // Control buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (Platform.isAndroid)
                    ElevatedButton(
                      onPressed: _getHealthConnectSdkStatus,
                      child: const Text("Check Health Connect Status"),
                    ),
                  if (Platform.isAndroid &&
                      _healthService.health.healthConnectSdkStatus !=
                          HealthConnectSdkStatus.sdkAvailable)
                    ElevatedButton(
                      onPressed: _installHealthConnect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Install Health Connect"),
                    ),
                  if (Platform.isIOS ||
                      (Platform.isAndroid &&
                          _healthService.health.healthConnectSdkStatus ==
                              HealthConnectSdkStatus.sdkAvailable)) ...[
                    ElevatedButton(
                      onPressed: _authorize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Authenticate"),
                    ),
                    ElevatedButton(
                      onPressed: _fetchData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Fetch Data"),
                    ),
                    ElevatedButton(
                      onPressed: _addData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Add Data"),
                    ),
                    ElevatedButton(
                      onPressed: _deleteData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Delete Data"),
                    ),
                    ElevatedButton(
                      onPressed: _fetchStepData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Fetch Steps"),
                    ),
                    ElevatedButton(
                      onPressed: _getIntervalBasedData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Get Interval Data"),
                    ),
                    if (Platform.isAndroid)
                      ElevatedButton(
                        onPressed: _revokeAccess,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Revoke Access"),
                      ),
                  ],
                ],
              ),
            ),
            const Divider(),
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: _content),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
