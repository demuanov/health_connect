import 'package:flutter/material.dart';
import 'package:health/health.dart';

/// Widget for displaying a list of health data points
class HealthDataListWidget extends StatelessWidget {
  final List<HealthDataPoint> healthDataList;
  final void Function(HealthDataPoint) onItemTap;

  const HealthDataListWidget({
    super.key,
    required this.healthDataList,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: healthDataList.length,
      itemBuilder: (context, index) {
        final healthPoint = healthDataList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            title: Text(
              healthPoint.type.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value: ${healthPoint.value}'),
                Text('Unit: ${healthPoint.unit}'),
                Text('Date: ${healthPoint.dateTo}'),
                Text('Source: ${healthPoint.sourceId}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => onItemTap(healthPoint),
          ),
        );
      },
    );
  }
}
