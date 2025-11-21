import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:carp_serializable/carp_serializable.dart';

/// Bottom sheet widget for displaying detailed health data information
class HealthDetailBottomSheet extends StatelessWidget {
  final HealthDataPoint? healthPoint;

  const HealthDetailBottomSheet({super.key, this.healthPoint});

  @override
  Widget build(BuildContext context) {
    if (healthPoint == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: Text('No health data available')),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getIconForHealthDataType(healthPoint!.type),
                      size: 32,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            healthPoint!.type.name.replaceAll('_', ' '),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${healthPoint!.value} ${healthPoint!.unit}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Details
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Value', '${healthPoint!.value}'),
                      _buildDetailRow('Unit', healthPoint!.unit.name),
                      _buildDetailRow(
                        'Type',
                        healthPoint!.type.name.replaceAll('_', ' '),
                      ),
                      _buildDetailRow(
                        'Date From',
                        _formatDateTime(healthPoint!.dateFrom),
                      ),
                      _buildDetailRow(
                        'Date To',
                        _formatDateTime(healthPoint!.dateTo),
                      ),
                      _buildDetailRow('Source ID', healthPoint!.sourceId),
                      _buildDetailRow('Source Name', healthPoint!.sourceName),
                      _buildDetailRow('UUID', healthPoint!.uuid),

                      const SizedBox(height: 16),

                      // Raw JSON data
                      ExpansionTile(
                        title: const Text('Raw Data (JSON)'),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              toJsonString(healthPoint!),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconForHealthDataType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return Icons.directions_walk;
      case HealthDataType.HEART_RATE:
        return Icons.favorite;
      case HealthDataType.WEIGHT:
        return Icons.monitor_weight;
      case HealthDataType.HEIGHT:
        return Icons.height;
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return Icons.bloodtype;
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_DEEP:
      case HealthDataType.SLEEP_LIGHT:
      case HealthDataType.SLEEP_REM:
        return Icons.bedtime;
      case HealthDataType.WORKOUT:
        return Icons.fitness_center;
      case HealthDataType.WATER:
        return Icons.water_drop;
      default:
        return Icons.health_and_safety;
    }
  }
}
