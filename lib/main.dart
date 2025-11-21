import 'package:flutter/material.dart';
import 'features/health/presentation/screens/main_health_screen.dart';

void main() => runApp(const HealthApp());

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainHealthScreen();
  }
}
