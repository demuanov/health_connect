# Health Connect Flutter App

A comprehensive Flutter application demonstrating integration with health data platforms (iOS HealthKit and Android Health Connect). This project has been completely reorganized to follow clean architecture principles and Flutter best practices.

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd health_connect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Features

- ✅ Health data authorization and permissions
- ✅ Fetch steps, heart rate, and other health metrics
- ✅ Add and delete health data points
- ✅ Platform-specific health data types support
- ✅ Clean, organized codebase following best practices
- ✅ Reusable UI components and widgets
- ✅ Comprehensive health data models

## 🏗 Architecture

This project follows **Clean Architecture** principles with feature-based organization:

- **Core Layer**: Shared utilities, constants, and enums
- **Feature Layer**: Health-specific business logic and UI
- **Presentation Layer**: Screens and reusable widgets
- **Data Layer**: Health service and API integration
- **Domain Layer**: Business models and entities

For detailed architecture documentation, see [ARCHITECTURE.md](ARCHITECTURE.md).

## 📱 Platform Support

| Platform | Health Integration | Status |
|----------|-------------------|--------|
| iOS | HealthKit | ✅ Full Support |
| Android | Health Connect | ✅ Full Support |
| Web | Limited | 🚧 Demo Only |
| Desktop | None | ❌ Not Available |

## 🔧 Requirements

### iOS
- iOS 13.0 or later
- Xcode 12.0 or later
- HealthKit entitlements configured

### Android  
- Android API 26 (8.0) or later
- Health Connect app installed
- Proper manifest permissions

## 📖 Usage Examples

### Basic Health Service
```dart
final healthService = HealthService();
await healthService.initialize();

// Request permissions
final authorized = await healthService.requestPermissions();

// Fetch health data
final data = await healthService.fetchHealthData(
  startTime: DateTime.now().subtract(Duration(hours: 24)),
  endTime: DateTime.now(),
);
```

### Using Health Widgets
```dart
HealthCardWidget(
  title: 'Steps Today',
  value: '10,000',
  icon: Icons.directions_walk,
  color: Colors.blue,
  subtitle: 'Great job!',
)
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
